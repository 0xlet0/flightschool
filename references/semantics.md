# 모델의 의미와 보장 범위

## 상태, 이벤트, 명령

송신 노드에는 `next : Nat`, `waiting : Bool`, 수신 노드에는 `next : Nat`이 있습니다. 이 카운터는 0부터 시작합니다. 데이터 번호 n의 payload는 “n번째 항목”으로 추상화합니다. payload 바이트열이나 무결성은 다루지 않습니다. receiver.next가 n에서 n+1로 바뀌는 것을 상위 애플리케이션에 한 번 전달했다고 해석합니다. 별도 delivery log는 없습니다.

하나의 명시적인 FIFO 큐에 `data n`과 `ack n`이 함께 들어갑니다. Message 생성자가 목적지를 구별하므로 별도 Node ID는 필요 없습니다. 전송은 뒤에 추가, 전달·손실은 앞에서 제거, 복제는 맨 앞을 연속 두 개로 바꿉니다. 실제 양방향 링크보다 순서 제약이 강한 작은 모델입니다. 임의 위치 전달·재정렬은 지원하지 않습니다.

start는 idle에서만 새 패킷 하나를 큐에 넣고 waiting으로 바꿉니다. waiting 중 start는 거절됩니다. timeout은 waiting에서 현재 번호를 재전송합니다. ACK가 도착하기 전에는 같은 번호를 사용하며, 일치하는 ACK를 받은 뒤에만 번호를 1 올립니다. 오래된 ACK는 큐에서 제거할 뿐 진행하지 않습니다.

데이터 수신에서 n = receiver.next이면 한 번 받아들이고 ACK를 만듭니다. n < receiver.next이면 중복이므로 카운터를 유지하고 ACK만 보냅니다. n > receiver.next이면 버립니다. `Nat` 번호는 순환하지 않습니다. 비트 번호를 다시 쓰는 프로토콜에서 오래된 패킷을 구별하는 문제는 별도로 다뤄야 합니다.

`interpret`는 첫 일치 규칙만 선택하고 명령을 순서대로 적용합니다. `none`은 일치 규칙 없음입니다. `advance`는 거절을 상태 유지로 바꾸고 `run`은 모든 이벤트를 소비합니다. `history`는 이벤트가 n개면 상태 n+1개를 포함하며, 거절 시 같은 상태가 반복됩니다. 반환 `List Action`은 이미 실행한 명령의 기록이지 아직 적용하지 않은 네트워크 패킷 목록이 아닙니다.

## 무엇을 증명했나요?

`Safe s`는 `sender.next ≤ receiver.next ∧ receiver.next ≤ sender.next + 1`입니다. `QueueValid s`는 큐의 모든 data n에 대해 `n ≤ sender.next`, 모든 ack n에 대해 `n < receiver.next`입니다. 후자는 위조되지 않은 ACK라는 실행 이력의 수치적 근거입니다. `Inv := Safe ∧ QueueValid`로 두 조건을 함께 유지합니다.

`initial_inv` → `action_preserves` → `actions_preserve` → `interpret_preserves` → `step_preserves` → `advance_preserves` → `run_preserves` / `history_preserves` 순으로 연결됩니다. interpreter 정리는 임의의 규칙표에 적용되지만, 명령 집합과 그 의미론은 고정되어 있습니다. 예를 들어 빈 규칙표도 이 Inv는 지킵니다. 이 불변식이 Stop-and-Wait의 전체 명세를 대체하지 않습니다.

국소 보존 정리 `timeout_local`은 timeout이 노드 진행 상태를 바꾸지 않음을, `old_data_local`은 오래된 데이터 전달이 receiver를 바꾸지 않음을 보입니다. `no_false_confirmation`은 임의 trace에서 확인 수가 실제 수신 수를 앞서지 않음을, `no_receiver_overrun`은 수신 수가 확인 수보다 두 개 이상 앞설 수 없음을 보입니다. `bad_unreachable`은 특정 잘못된 상태에 도달하지 못한다는 형태로 같은 안전성을 사용합니다.

`State` 타입 자체는 `sender.next = 2, receiver.next = 0`을 허용합니다. 보장은 초기 상태에서 정의된 이벤트 의미론을 따라온 경우에 한정됩니다. `ValidMessage`는 데이터 내용의 정확성, 보낸 모든 항목의 최종 전달, 실제 네트워크와 모델의 일치를 증명하지 않습니다.

## safety와 liveness

Safety는 “잘못된 일이 발생하지 않는다”입니다. 이 모델에서는 허위 수신 확인이나 수신자가 두 패킷 앞서는 상태가 금지됩니다. 유한한 나쁜 prefix 하나로 위반을 보여 줄 수 있습니다.

Liveness는 “좋은 일이 결국 발생한다”입니다. 예를 들어 시작한 전송이 결국 ACK로 완료된다는 주장입니다. 모델에는 환경이 영원히 drop을 선택하거나 timeout을 전혀 발생시키지 않는 것도 허용됩니다. `repeated_loss n`은 임의의 유한 n번 재시도·손실 후에도 같은 대기 상태임을 증명합니다. 이 자체가 무한 시간 논리를 구현한 정리는 아닙니다.

완료를 주장하려면 공정한 실행과 전달 가정이 필요합니다. waiting인 동안 재시도 기회가 계속 주어지고, 재전송 데이터가 결국 수신되며, 그 데이터로 생긴 ACK도 결국 송신자에게 전달되어 처리되어야 합니다. “언젠가 데이터가 도착한다”만으로는 부족합니다. ACK가 영원히 사라지면 sender는 계속 대기합니다. 그러한 가정을 형식화한 liveness 증명은 선택 심화이며 이 저장소의 완료 보장에 포함되지 않습니다.

## 검증 수단의 차이

| 수단 | 여기서 보장하는 것 | 보장하지 않는 것 |
|---|---|---|
| 타입 검사 | State/Event/Action의 형태, 함수 입력·출력의 일관성 | 잘못된 ACK가 pending을 지우는 논리 오류 |
| 테스트 (`#guard`) | 지정한 입력의 결과와 기대값 일치 | 나열하지 않은 모든 trace |
| 시뮬레이션 (`#eval`, 실행 로그) | 선택한 이벤트 순서에서 모델의 계산·중간 상태 관찰 | 실제 시간·소켓의 행동, 모든 스케줄 |
| 형식 증명 (`theorem`) | 명시한 가정 아래 명시한 명제가 모든 입력에서 성립 | 모델링 누락, 현실 구현과의 일치, 증명하지 않은 liveness |

`#guard`가 많아도 귀납 정리를 대신하지 않습니다. 정리가 있어도 잘못 선택한 추상화가 현실을 정확히 나타내는지는 따로 검토해야 합니다. Lean 커널은 증명 항을 검사합니다. 산술 자동화 `omega`도 검사 가능한 증명을 생성하며 수치 실험을 일반 증명으로 바꾸는 마술이 아닙니다.

## 선택 심화 — 첫 주 이후

- 모든 Action에서 receiver.next가 단조 증가함을 별도 정리로 표현하기.
- 큐에서 임의 위치를 전달하도록 Event에 인덱스를 추가하고 단계 보존 재검토하기.
- payload와 상위 전달 로그를 추가해 순서·중복 제거 명세를 강화하기.
- 무한 실행과 공정성, eventual delivery 가정을 정의하고 liveness 증명하기.
- 번호를 유한 비트로 바꿀 때 오래된 중복이 만드는 반례 찾기.

매크로, parser, 외부 DSL, code generation, 고급 의존 타입은 이 과정의 구현 범위에 없습니다.
