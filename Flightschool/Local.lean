/-! 2회차: 실패를 Option으로, 부수 효과를 Action 목록으로 표현합니다. -/
namespace Flightschool.Local

structure State where
  pending : Option Nat := none
  deriving Repr, DecidableEq

inductive Event where
  | send (packet : Nat)
  | ack (packet : Nat)
  | timeout
  deriving Repr, DecidableEq

inductive Action where
  | transmit (packet : Nat)
  deriving Repr, DecidableEq

def step (s : State) (e : Event) : Option (State × List Action) :=
  match s.pending, e with
  | none, .send n => some (⟨some n⟩, [.transmit n])
  | some n, .ack k => if n == k then some (⟨none⟩, []) else none
  | some n, .timeout => some (s, [.transmit n])
  | _, _ => none

-- 이 수업의 정책: 거절된 이벤트는 상태를 그대로 둡니다.
def advance (s : State) (e : Event) : State :=
  match step s e with
  | none => s
  | some (t, _) => t

def run (s : State) : List Event → State
  | [] => s
  | e :: es => run (advance s e) es

#eval run {} [.send 7, .timeout, .ack 6, .ack 7]

theorem timeout_preserves (s : State) : advance s .timeout = s := by
  cases s with
  | mk p => cases p <;> simp [advance, step]

theorem wrong_ack (n k : Nat) (h : n ≠ k) :
    step ⟨some n⟩ (.ack k) = none := by
  simp [step, h]

theorem pending_blocks_send (n k : Nat) :
    step ⟨some n⟩ (.send k) = none := by
  rfl

end Flightschool.Local
