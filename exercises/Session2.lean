import Flightschool.Local

namespace Exercises.Session2
open Flightschool.Local

-- E3 완성: send 7, 잘못된 ACK, timeout, 올바른 ACK를 순서대로 넣으세요.
def recovery : List Event := []
#eval run {} recovery

-- E4 디버깅: 번호를 비교하지 않는 아래 코드는 어떤 입력에서 잘못될까요?
def buggyAck (s : State) (e : Event) : State :=
  match e with
  | .ack _ => ⟨none⟩
  | _ => s
#eval buggyAck ⟨some 7⟩ (.ack 6)

-- E5 증명: 아래 계산 증명을 cases와 simp를 사용한 증명으로 확장하세요.
-- 목표: 모든 State s에 대해 advance s .timeout = s.
example : advance ⟨some 7⟩ .timeout = ⟨some 7⟩ := by rfl

end Exercises.Session2
