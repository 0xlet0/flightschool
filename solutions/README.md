# 해답을 읽는 순서

모든 `.lean` 해답은 기본 `lake build`에서 검증됩니다. 수업별 해설은 아래 링크에 있습니다.

| 해답 | 먼저 비교할 것 | 해설 |
|---|---|---|
| [Session1.lean](Session1.lean) | 추가한 timeout 분기와 기본 분기 | [1회차](../lessons/01-state.md#해답과-해설) |
| [Session2.lean](Session2.lean) | ACK 번호 검사, Option의 두 경우 | [2회차](../lessons/02-execution.md#해답과-해설) |
| [Session3.lean](Session3.lean) | generalizing s와 귀납 가정의 타입 | [3회차](../lessons/03-network.md#해답과-해설) |
| [Session4.lean](Session4.lean) | 오래된 ACK 중간 상태, history 정리 | [4회차](../lessons/04-ast.md#해답과-해설) |

`fixedAck`는 검증된 전이를 재사용합니다. 번호 비교를 직접 다시 구현했다면 잘못된 ACK, 올바른 ACK, pending 없음, timeout을 모두 확인하세요. 같은 결과라도 의미가 다를 수 있으므로 recovery가 빈 trace가 아닌지도 검사합니다.

`bad_unreachable`은 모순 증명의 작은 예입니다. `run {} events = bad`를 가정하고 이미 증명한 모든 trace의 부등식에 대입하면 불가능한 자연수 부등식이 됩니다. “bad를 표현할 수 없다”와 “bad에 도달할 수 없다”는 다른 주장입니다.
