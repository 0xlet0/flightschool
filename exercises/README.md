# 연습 파일 사용법

각 파일은 처음부터 컴파일됩니다. 시작 파일의 빈 목록이나 잘못된 예측은 의도적이며, 논리적으로 틀린 함수도 타입이 맞으면 컴파일될 수 있습니다. 과제 충족 여부는 각 수업의 완료 조건으로 판단합니다. 미완성 증명 구멍을 남기지 않고, 작은 계산 증명에서 일반 정리로 확장합니다.

```sh
lake env lean exercises/Session1.lean
lake build
```

| 번호 | 종류 | 편집 대상 | 완료 조건 |
|---|---|---|---|
| E1 | 읽기 | Session1.prediction | waiting 예측, 두 번 send의 횟수 설명 |
| E2 | 수정 | Session1.retryStep | waiting timeout만 시도 수 증가 |
| E3 | 완성 | Session2.recovery | 지정한 4개 이벤트와 중간 pending 확인 |
| E4 | 디버깅 | Session2.buggyAck | ACK 6이 pending 7을 지우지 않음 |
| E5 | 증명 | Session2.example | 모든 s에서 timeout pending 보존 |
| E6 | 설계 | Session3.ackLoss | ACK 손실 후 재전송 완료, 수신 수 1 |
| E7 | 증명 | Session3.safe_part | 목표를 Safe s로 바꾸고 두 부분 증명 |
| E8 | 귀납 | Session3 | 임의 초기 Inv에서 모든 trace의 Inv 증명 |
| E9 | AST | Session4.rules | waiting timeout 규칙 추가, idle timeout 거절 |
| E10 | 설계 | Session4.twoPackets | 오래된 ACK 무시 후 두 패킷 완료 |
| E11 | 증명 | Session4 | 모든 history 상태의 Inv 증명 |

E8 목표는 `all_events_preserve (es : List Event) (s : State) (h : Inv s) : Inv (run s es)`입니다. `run_preserves`를 호출하는 대신 귀납 구조를 직접 작성합니다.

E11 목표는 `every_prefix (events : List Event) : ∀ s ∈ history {} events, Inv s`입니다. 한 trace를 검사하는 것으로 대체하지 않습니다.

힌트는 [1회](../lessons/01-state.md), [2회](../lessons/02-execution.md), [3회](../lessons/03-network.md), [4회](../lessons/04-ast.md)에 단계별로 있습니다. 해답을 읽은 후에는 파일을 닫고 다시 작성하세요. 해답 파일을 import해서 과제를 우회하지 않도록 각 연습은 필요한 core만 import합니다.
