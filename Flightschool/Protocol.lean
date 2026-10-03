/-!
3–4회차 공통 의미론. 패킷 번호가 곧 추상적인 payload 식별자입니다.
송신 노드와 수신 노드 사이의 큐는 양방향 메시지를 담습니다.
-/
namespace Flightschool

structure Sender where
  next : Nat := 0
  waiting : Bool := false
  deriving Repr, DecidableEq

structure Receiver where
  next : Nat := 0
  deriving Repr, DecidableEq

inductive Message where
  | data (seq : Nat)
  | ack (seq : Nat)
  deriving Repr, DecidableEq

structure State where
  sender : Sender := {}
  receiver : Receiver := {}
  queue : List Message := []
  deriving Repr, DecidableEq

inductive Event where
  | start | timeout | deliver | drop | duplicate
  deriving Repr, DecidableEq

-- 제한된 AST: Lean 함수나 임의의 코드를 필드에 넣지 않습니다.
inductive Guard where
  | idle | waiting | dataReady | ackReady | nonempty
  deriving Repr, DecidableEq

inductive Action where
  | send | retry | receiveData | receiveAck | discard | copy
  deriving Repr, DecidableEq

structure Rule where
  event : Event
  guard : Guard
  actions : List Action
  deriving Repr, DecidableEq

def evalGuard (s : State) : Guard → Bool
  | .idle => !s.sender.waiting
  | .waiting => s.sender.waiting
  | .dataReady => match s.queue with | .data _ :: _ => true | _ => false
  | .ackReady => match s.queue with | .ack _ :: _ => true | _ => false
  | .nonempty => !s.queue.isEmpty

-- 각 명령의 의미. 자료가 없는 명령은 아무 일도 하지 않습니다.
def execAction (s : State) : Action → State
  | .send => { s with
      sender := { s.sender with waiting := true }
      queue := s.queue ++ [.data s.sender.next] }
  | .retry => { s with queue := s.queue ++ [.data s.sender.next] }
  | .receiveData => match s.queue with
    | .data n :: rest =>
      if n == s.receiver.next then
        { s with receiver := ⟨s.receiver.next + 1⟩, queue := rest ++ [.ack n] }
      else if n < s.receiver.next then
        { s with queue := rest ++ [.ack n] }
      else { s with queue := rest }
    | _ => s
  | .receiveAck => match s.queue with
    | .ack n :: rest =>
      if s.sender.waiting && n == s.sender.next then
        { s with sender := ⟨s.sender.next + 1, false⟩, queue := rest }
      else { s with queue := rest }
    | _ => s
  | .discard => { s with queue := s.queue.drop 1 }
  | .copy => match s.queue with
    | [] => s
    | m :: rest => { s with queue := m :: m :: rest }

def execActions (s : State) : List Action → State
  | [] => s
  | a :: rest => execActions (execAction s a) rest

-- 첫 번째로 일치하는 규칙을 선택합니다. 거절은 none으로 표시합니다.
def interpret (rules : List Rule) (s : State) (e : Event) :
    Option (State × List Action) :=
  match rules with
  | [] => none
  | r :: rest =>
    if r.event == e && evalGuard s r.guard then
      some (execActions s r.actions, r.actions)
    else interpret rest s e

def protocol : List Rule := [
  ⟨.start, .idle, [.send]⟩,
  ⟨.timeout, .waiting, [.retry]⟩,
  ⟨.deliver, .dataReady, [.receiveData]⟩,
  ⟨.deliver, .ackReady, [.receiveAck]⟩,
  ⟨.drop, .nonempty, [.discard]⟩,
  ⟨.duplicate, .nonempty, [.copy]⟩]

def step : State → Event → Option (State × List Action) := interpret protocol

def advance (s : State) (e : Event) : State :=
  match step s e with
  | none => s
  | some (t, _) => t

def run (s : State) : List Event → State
  | [] => s
  | e :: es => run (advance s e) es

-- 초기 상태와 모든 중간 상태를 포함하므로 prefix 검사에도 씁니다.
def history (s : State) : List Event → List State
  | [] => [s]
  | e :: es => s :: history (advance s e) es

-- 3회차에는 규칙표 없이 이 함수를 먼저 읽습니다.
def directStep (s : State) (e : Event) : Option (State × List Action) :=
  match e with
  | .start => if evalGuard s .idle then some (execAction s .send, [.send]) else none
  | .timeout => if evalGuard s .waiting then some (execAction s .retry, [.retry]) else none
  | .deliver => match s.queue with
    | .data _ :: _ => some (execAction s .receiveData, [.receiveData])
    | .ack _ :: _ => some (execAction s .receiveAck, [.receiveAck])
    | [] => none
  | .drop => if evalGuard s .nonempty then some (execAction s .discard, [.discard]) else none
  | .duplicate => if evalGuard s .nonempty then some (execAction s .copy, [.copy]) else none

-- AST로 바꿔도 실행 의미가 같다는 연결 정리입니다.
theorem interpreter_matches_direct (s : State) (e : Event) : step s e = directStep s e := by
  cases hw : s.sender.waiting <;> cases e <;> cases h : s.queue with
  | nil => simp [step, interpret, protocol, execActions, directStep, evalGuard, h, hw]
  | cons m ms => cases m <;> simp [step, interpret, protocol, execActions, directStep, evalGuard, h, hw]

end Flightschool
