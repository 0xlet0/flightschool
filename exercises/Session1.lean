import Flightschool.Basics

namespace Exercises.Session1
open Flightschool.Basics

-- E1 읽기: 실행 전에 예상값을 고치고 #eval 결과와 비교하세요.
def prediction : Phase := .idle
#eval prediction
#eval (step {} .send).phase

-- E2 수정: waiting일 때 timeout이 sent를 증가시키도록 바꾸세요.
-- sent는 이 연습에서만 '전송 시도 횟수'를 뜻합니다.
def retryStep (s : State) (e : Event) : State := step s e
#eval retryStep ⟨.waiting, 1⟩ .timeout

end Exercises.Session1
