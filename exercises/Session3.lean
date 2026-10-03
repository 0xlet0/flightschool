import Flightschool.Invariants

namespace Exercises.Session3
open Flightschool

-- E6 설계: data는 도착하지만 ACK가 한 번 사라지는 trace를 만드세요.
def ackLoss : List Event := []
#eval run {} ackLoss

-- E7 증명: Safe를 '펼친' 상태에서 두 부분을 constructor와 exact로 채웁니다.
-- 현재는 첫 번째 부분만 있습니다. 전체 Safe s로 목표를 바꾸세요.
theorem safe_part (s : State) (h : Inv s) : s.sender.next ≤ s.receiver.next := by
  exact h.1.1

-- E8 증명: run_preserves를 참고해 직접 induction으로 같은 정리를 쓰세요.
-- 처음에는 아래 한 줄로 증명과 실행을 연결해 봅니다.
theorem safe_after (events : List Event) : Safe (run {} events) := by
  exact (run_preserves events {} initial_inv).1

end Exercises.Session3
