import Flightschool.Traces

namespace Exercises.Session4
open Flightschool

-- E9 AST 설계: timeout 재전송 규칙을 추가하세요. Lean 함수를 Rule에 넣지 않습니다.
def rules : List Rule := [⟨.start, .idle, [.send]⟩]
#eval interpret rules (advance {} .start) .timeout

-- E10 trace 설계: 두 패킷이 완료되고 오래된 ACK가 무시되는 trace를 만드세요.
def twoPackets : List Event := []
#eval run {} twoPackets

-- E11 증명: '모든 prefix 상태의 Inv'를 history_preserves로 얻으세요.
-- 아래는 최종 상태만 다룹니다. 요구하는 정리는 exercises/README.md에 있습니다.
theorem finalSafe (events : List Event) : Safe (run {} events) := by
  exact (run_preserves events {} initial_inv).1

end Exercises.Session4
