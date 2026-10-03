# 3회차 — 큐와 불변식

120분: 큐 손계산 25 / 실행·반례 25 / 불변식 읽기 25 / 귀납 과제 35 / 정리 10. 목표는 두 노드와 큐를 함께 모델링하고 한 단계의 보존에서 임의 길이 실행의 보존으로 넘어가는 것입니다.

## 먼저 네트워크를 실행하기

```sh
lake exe flightschool
lake env lean exercises/Session3.lean
```

[Protocol.lean](../Flightschool/Protocol.lean)에서 지금은 `State`, `Message`, `execAction`, `directStep`을 읽습니다. `Guard`, `Rule`, `interpret`의 구현은 다음 회차에서 읽어도 됩니다. `interpreter_matches_direct`가 두 실행 방식의 결과가 같음을 연결합니다.

`sender.next`는 다음 전송 번호이자 지금까지 ACK로 확인한 수, `receiver.next`는 다음에 받을 번호이자 받아들인 수입니다. 실제 payload 대신 번호만 전송합니다. 하나의 FIFO 큐에 방향이 구별되는 `.data n`, `.ack n`을 담습니다. `.deliver`는 맨 앞 한 개만 전달합니다. `.drop`은 맨 앞 한 개를 잃고, `.duplicate`는 맨 앞 메시지를 연속 두 개로 만듭니다. 이벤트의 선택은 환경 역할입니다.

수신자는 기대한 번호를 받으면 수신 수를 1 늘리고 ACK를 만듭니다. 오래된 데이터는 다시 세지 않지만 ACK를 재전송합니다. 미래 번호는 버립니다. 송신자는 waiting이며 현재 번호와 ACK가 일치할 때만 진행합니다.

## 손으로 추적할 표

`[start, deliver, drop, timeout, deliver, deliver]`을 실행하기 전에 빈 칸을 채우세요.

| 직후 이벤트 | sender.next | waiting | receiver.next | queue |
|---|---:|---|---:|---|
| 초기 | 0 | false | 0 | `[]` |
| start | 0 | true | 0 | `[data 0]` |
| deliver | 0 | true | 1 | `[ack 0]` |
| drop | ? | ? | ? | ? |
| timeout | ? | ? | ? | ? |
| deliver | ? | ? | ? | ? |
| deliver | ? | ? | ? | ? |

## 불변식은 무엇을 말하나요?

[Invariants.lean](../Flightschool/Invariants.lean)의 `Safe s`는 한 상태에 대한 명제입니다.

```text
sender.next ≤ receiver.next ≤ sender.next + 1
```

왼쪽은 실제 수신 전에 ACK 완료 수가 앞서지 않음, 오른쪽은 수신자가 두 개 이상 앞서지 않음입니다. 이것만으로는 다음 단계를 증명하기에 부족합니다. 예를 들어 카운터가 모두 0이어도 큐에 `ack 99`를 마음대로 넣으면 큐가 프로토콜 이력과 맞지 않습니다. `QueueValid`는 data 번호가 발급 범위를 넘지 않고, ACK 번호가 실제 수신 수보다 작다는 조건입니다. `Inv`는 `Safe ∧ QueueValid`입니다.

읽는 순서:

1. `initial_inv`: 초기 상태가 Inv를 만족합니다.
2. `action_preserves`, `step_preserves`: 한 명령·한 단계가 Inv를 보존합니다. 수치 분기의 `omega`는 자연수 부등식을 풀어주는 제공 보조 도구입니다. 첫 주에 이 긴 분기를 직접 재작성하지 않습니다.
3. `advance_preserves`: 거절된 이벤트도 상태 유지이므로 Inv가 유지됩니다.
4. `run_preserves`: 목록 길이에 대한 귀납으로 모든 유한 trace를 다룹니다.
5. `history_preserves`: 최종 상태뿐 아니라 초기 상태와 모든 중간 상태도 다룹니다.

## 작은 전술 도구

`intro`는 “모든 x”나 “A라면”의 x·가정을 꺼냅니다. `exact`는 현재 목표와 같은 타입의 증명을 제시합니다. `constructor`는 `A ∧ B`를 두 목표로 나눕니다. `apply`는 사용할 정리의 결론과 현재 목표를 맞추고 필요한 가정을 새 목표로 만듭니다. `induction`은 빈 목록과 앞 원소가 있는 목록을 나눕니다. [요약표](../references/lean-cheatsheet.md)를 곁에 두세요.

## 실습 E6–E8

[시작 파일](../exercises/Session3.lean)을 수정합니다.

- **설계 E6:** 위 ACK 손실 trace를 만들어 sender와 receiver가 모두 1로 끝나는지 검사합니다. 데이터 손실과 ACK 손실에서 재전송을 받은 수신자의 분기가 어떻게 다른지 말하세요.
- **증명 E7:** `safe_part`의 목표를 `Safe s`로 바꾸고 `constructor`, `exact h.1.1`, `exact h.1.2`로 완성하세요.
- **귀납 E8:** `safe_after`의 한 줄 해답 대신, `all_events_preserve (es : List Event) (s : State) (h : Inv s) : Inv (run s es)`를 새로 쓰고 직접 증명하세요.

## 단계별 힌트

1. E6: ACK 손실 후 receiver는 이미 1입니다. 재전송 data 0을 새 데이터로 세면 버그입니다.
2. E7: `h.1`은 Safe, `h.2`는 QueueValid입니다. Safe의 두 부분은 다시 `.1`, `.2`로 꺼냅니다.
3. E8: `induction es generalizing s with`로 시작합니다. 재귀 호출에서 상태가 달라지므로 `s`를 일반화합니다.
4. E8: 빈 목록은 `exact h`. cons 경우는 `apply ih` 다음 `exact advance_preserves s e h`입니다. 전체 trace 정리 자체를 다시 부르지 않습니다.

## 해답과 해설

[해답](../solutions/Session3.lean)을 참고하세요. 표의 나머지는 `(0,true,1,[])`, `(0,true,1,[data 0])`, `(0,true,1,[ack 0])`, `(1,false,1,[])`입니다. 두 번째 data 0은 ACK만 다시 만듭니다.

귀납 가정은 “나머지 이벤트들을 **어떤 안전한 상태에서** 실행해도 안전하다”입니다. `generalizing s`를 빼면 초기 s에 대해서만 가정을 얻어 바뀐 상태에 쓸 수 없습니다. 이 실패를 직접 보고 복구해 보세요. 핵심은 복잡한 전술보다 안전한 한 단계들을 이어 붙이는 논리입니다.
