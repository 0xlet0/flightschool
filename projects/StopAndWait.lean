import Flightschool.Traces

/-! 최종 제출물의 검증된 참조 구현. 설명은 projects/README.md와 함께 읽습니다. -/
namespace Projects.StopAndWait
open Flightschool

-- 같은 AST를 실행과 증명 양쪽에서 사용합니다.
def model : List Rule := protocol

def execute (s : State) (e : Event) : Option (State × List Action) :=
  interpret model s e

example (s : State) (e : Event) : execute s e = step s e := by rfl

-- local invariant: 재전송을 요청해도 노드의 진행 상태는 바뀌지 않습니다.
theorem local_invariant (s : State) :
    (advance s .timeout).sender = s.sender ∧
    (advance s .timeout).receiver = s.receiver := by
  exact timeout_local s

-- trace invariant: 초기 상태를 포함한 모든 중간 상태가 안전합니다.
theorem trace_invariant (events : List Event) :
    ∀ s ∈ history {} events, Inv s := by
  intro s hs
  exact history_preserves events {} initial_inv s hs

-- 타입으로 표현할 수 있지만 실행으로 도달할 수 없는 상태입니다.
def badState : State := ⟨⟨2, false⟩, ⟨0⟩, []⟩

theorem bad_unreachable (events : List Event) : run {} events ≠ badState := by
  intro h
  have safe := no_false_confirmation events
  rw [h] at safe
  simp [badState] at safe

#guard run {} normal = completed 1
#guard run {} lostData = completed 1
#guard run {} lostAck = completed 1
#guard run {} duplicateData = completed 1
#guard run {} duplicateAck = completed 1
#guard run {} staleAck = completed 2

end Projects.StopAndWait
