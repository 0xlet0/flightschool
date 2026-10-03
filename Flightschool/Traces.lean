import Flightschool.Invariants

namespace Flightschool

def normal : List Event := [.start, .deliver, .deliver]
def lostData : List Event := [.start, .drop, .timeout, .deliver, .deliver]
def lostAck : List Event := [.start, .deliver, .drop, .timeout, .deliver, .deliver]
def duplicateData : List Event := [.start, .duplicate, .deliver, .deliver, .deliver, .deliver]
def duplicateAck : List Event := [.start, .deliver, .duplicate, .deliver, .deliver]
def staleAck : List Event :=
  [.start, .deliver, .duplicate, .deliver, .start, .deliver, .deliver, .deliver]

def completed (n : Nat) : State := ⟨⟨n, false⟩, ⟨n⟩, []⟩

#guard run {} normal = completed 1
#guard run {} lostData = completed 1
#guard run {} lostAck = completed 1
#guard run {} duplicateData = completed 1
#guard run {} duplicateAck = completed 1
#guard run {} staleAck = completed 2
#guard step {} .timeout = none
#guard step {} .deliver = none
#guard run {} [.start, .start] = run {} [.start]
#guard (run {} [.start, .deliver, .duplicate, .deliver, .start, .deliver]).sender.next = 1
#guard (run {} [.start, .duplicate, .deliver, .deliver]).receiver.next = 1

-- 전달을 계속 잃어버리면 진전은 없습니다. 안전하지만 완료되지 않습니다.
def lossCycle : List Event := [.timeout, .drop]
def waitingEmpty : State := ⟨⟨0, true⟩, ⟨0⟩, []⟩
#guard run {} [.start, .drop] = waitingEmpty
#guard run waitingEmpty lossCycle = waitingEmpty

theorem loss_cycle_stutters : run waitingEmpty lossCycle = waitingEmpty := by
  rfl

-- timeout은 노드의 진행 번호를 바꾸지 않는 local invariant입니다.
theorem timeout_local (s : State) :
    (advance s .timeout).sender = s.sender ∧
    (advance s .timeout).receiver = s.receiver := by
  simp only [advance, interpreter_matches_direct, directStep]
  cases h : s.sender.waiting <;> simp [evalGuard, h, execAction]

-- local invariant: 오래된 data를 전달해도 수신 횟수는 늘어나지 않습니다.
theorem old_data_local (s : State) (n : Nat) (rest : List Message)
    (hq : s.queue = .data n :: rest) (old : n < s.receiver.next) :
    (advance s .deliver).receiver = s.receiver := by
  have ne : n ≠ s.receiver.next := by omega
  simp [advance, interpreter_matches_direct, directStep, hq, execAction, ne, old]

-- 임의 횟수의 반복 손실로도 완료를 강제할 수 없음을 유한 trace로 보입니다.
def repeatLoss : Nat → List Event
  | 0 => []
  | n + 1 => lossCycle ++ repeatLoss n

theorem run_append (xs ys : List Event) (s : State) :
    run s (xs ++ ys) = run (run s xs) ys := by
  induction xs generalizing s with
  | nil => rfl
  | cons e es ih => exact ih (advance s e)

theorem repeated_loss (n : Nat) : run waitingEmpty (repeatLoss n) = waitingEmpty := by
  induction n with
  | zero => rfl
  | succ n ih => simpa [repeatLoss, run_append, loss_cycle_stutters] using ih

def scenarios : List (String × List Event) := [
  ("정상 전송", normal), ("데이터 손실 후 재전송", lostData),
  ("ACK 손실 후 재전송", lostAck), ("데이터 중복", duplicateData),
  ("ACK 중복", duplicateAck), ("다음 전송 중 오래된 ACK", staleAck)]

def summary (s : State) : String :=
  s!"sender.next={s.sender.next}, waiting={s.sender.waiting}, receiver.next={s.receiver.next}, queue={repr s.queue}"

def simulate (s : State) : List Event → IO State
  | [] => pure s
  | e :: es => do
    match step s e with
    | none =>
      IO.println s!"  {repr e}: 거절 (상태 유지)"
      simulate s es
    | some (t, as) =>
      IO.println s!"  {repr e} -> {repr as}\n    {summary t}"
      simulate t es

end Flightschool
