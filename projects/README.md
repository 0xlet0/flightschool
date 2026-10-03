# 최종 과제 — 작은 Stop-and-Wait

4회차 마지막 35분에 짝 검토를 시작하고, 개인 60분으로 제출물을 정리합니다. 앞선 연습 결과를 이어 붙이는 과제이며 백지에서 긴 산술 증명을 다시 만들 필요는 없습니다. [참조 제출물](StopAndWait.lean)은 처음부터 빌드됩니다. 먼저 요구사항에 맞춰 설명과 trace를 직접 작성한 뒤 비교하세요.

## 제출 구성

1. **실행 가능한 모델:** `State`, `Event`, `Guard`, `Action`, `Rule`의 제한된 AST와 `State → Event → Option (State × List Action)` 의미론. 기존 `Flightschool` core를 import해 사용하거나 규칙표를 직접 작성해도 됩니다. 함수로 모든 규칙을 우회하면 AST 과제를 충족하지 못합니다.
2. **trace 여섯 개:** 정상 전송, 데이터 손실, ACK 손실, 데이터 중복, ACK 중복, 다음 전송 중 오래된 ACK. 각 초기 상태·이벤트·예상 최종 상태를 적고, 중복 사례는 receiver가 한 번만 증가하는 중간값도 검사하세요.
3. **local invariant:** `timeout_local` 또는 `old_data_local`에 해당하는 국소 보존 성질 하나. 어떤 이벤트와 전제에서 어떤 필드가 유지되는지 명시합니다.
4. **trace invariant:** 한 상태의 `Inv`를 정의하고 초기·단계 보존을 연결해 모든 유한 trace에 대해 증명합니다. `history_preserves`로 모든 prefix 상태를 포함하세요. 제공 보조 정리를 사용하되 본인의 `intro`/`exact` 또는 귀납 증명을 포함합니다.
5. **의미 있는 safety:** `badState` 도달 불가능, 허위 ACK 완료 금지, 수신자가 두 개 이상 앞설 수 없음 중 하나를 증명합니다. 구체적인 `#guard` 하나로 대체하지 않습니다.
6. **설명 문서:** 아래 질문에 각 2~3문장으로 답합니다. `projects/REPORT.md`를 만들어도 되고 코드의 한국어 주석에 작성해도 됩니다.

## 설명 질문

- `sender.next`, `receiver.next`, waiting, 큐는 각각 무엇인가요? timeout을 실제 시계 대신 Event로 둔 이유는 무엇인가요?
- 같은 데이터를 다시 받아도 receiver.next가 증가하지 않는 분기는 어디인가요? ACK를 다시 보내는 이유는 무엇인가요?
- safety와 liveness는 어떻게 다른가요? `repeatLoss`가 알려 주는 것은 무엇이고 증명하지 않는 것은 무엇인가요?
- 완료를 말하려면 어떤 외부 가정이 필요한가요? 재시도 timeout이 계속 발생하고 재전송된 데이터 및 그 응답 ACK가 결국 전달되며, 해당 전달 이벤트가 실행되어야 합니다. 데이터만 eventual delivery여도 ACK가 계속 손실되면 송신자는 끝나지 않습니다. 이 과정에서는 그러한 가정 아래의 liveness 정리를 형식 증명하지 않습니다.
- 테스트·시뮬레이션·타입·증명이 각각 보장하는 범위와 한계는 무엇인가요?
- 이 모델에 없는 현상 두 개와, 추가 시 바뀔 상태·이벤트·불변식을 말해 보세요.

## 참조 결과

| trace 이름 | sender.next | receiver.next | waiting | queue |
|---|---:|---:|---|---|
| normal | 1 | 1 | false | `[]` |
| lostData | 1 | 1 | false | `[]` |
| lostAck | 1 | 1 | false | `[]` |
| duplicateData | 1 | 1 | false | `[]` |
| duplicateAck | 1 | 1 | false | `[]` |
| staleAck | 2 | 2 | false | `[]` |

[Traces.lean](../Flightschool/Traces.lean)에 이벤트 목록과 중간 상태 검사가 있습니다. `projects/StopAndWait.lean`은 core의 같은 interpreter를 재사용하고 local/trace/safety 정리를 제출물 형태로 묶습니다. 상세 의미와 질문 해설은 [semantics.md](../references/semantics.md)에 있습니다.

```sh
lake build
lake env lean projects/StopAndWait.lean
lake exe flightschool
bash scripts/check.sh
```

새 `.lean` 파일을 `projects/`에 두면 Lake의 `projects.+` 범위에 들어가 기본 빌드에서 검사됩니다. 새 namespace를 사용하세요. 모든 제출 증명은 구멍 없이 완성합니다.

## 자기 점검

- 정상 trace만 통과하면 실행 사례가 부족합니다.
- 최종 상태만 안전하면 중간 상태의 보장은 아직 설명하지 않은 것입니다.
- 증명한 명제가 참이어도 protocol이 항상 완료한다는 뜻은 아닙니다.
- 임의 State에서 Safe는 성립하지 않습니다. 초기 상태와 도달 가능성 가정을 지우지 마세요.
- 규칙을 추가할 때 반환 Action을 다시 적용하지 마세요. 이미 다음 State에 반영되어 있습니다.
