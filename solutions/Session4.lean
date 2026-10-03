import Flightschool.Traces
namespace Solutions.Session4
open Flightschool

def rules : List Rule := [⟨.start, .idle, [.send]⟩, ⟨.timeout, .waiting, [.retry]⟩]
#guard (interpret rules (advance {} .start) .timeout).isSome
#guard interpret rules {} .timeout = none

def twoPackets : List Event :=
  [.start, .deliver, .duplicate, .deliver, .start, .deliver, .deliver, .deliver]
#guard run {} twoPackets = completed 2

theorem every_prefix (events : List Event) :
    ∀ s ∈ history {} events, Inv s := by
  intro s hs
  exact history_preserves events {} initial_inv s hs

-- 잘못된 상태를 실제로 표현할 수 있지만 정상 실행으로는 만들 수 없습니다.
def bad : State := ⟨⟨2, false⟩, ⟨0⟩, []⟩
theorem bad_unreachable (events : List Event) : run {} events ≠ bad := by
  intro eq
  have h := no_false_confirmation events
  rw [eq] at h
  simp [bad] at h
end Solutions.Session4
