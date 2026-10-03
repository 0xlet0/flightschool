/-! 1회차: 작은 상태를 만들고 함수로 움직입니다. -/
namespace Flightschool.Basics

inductive Phase where
  | idle | waiting
  deriving Repr, DecidableEq

structure State where
  phase : Phase := .idle
  sent : Nat := 0
  deriving Repr, DecidableEq

inductive Event where
  | send | ack | timeout
  deriving Repr, DecidableEq

def step (s : State) (e : Event) : State :=
  match s.phase, e with
  | .idle, .send => { phase := .waiting, sent := s.sent + 1 }
  | .waiting, .ack => { s with phase := .idle }
  | _, _ => s

#check State
#check step
#eval step {} .send
#eval step (step {} .send) .ack

-- 같은 입력을 계산하여 같은 결과가 되므로 rfl로 증명합니다.
theorem idle_timeout (n : Nat) :
    step ⟨.idle, n⟩ .timeout = ⟨.idle, n⟩ := by
  rfl

end Flightschool.Basics
