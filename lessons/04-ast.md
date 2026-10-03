# 4회차 — 같은 모델로 실행하고 증명하기

120분: AST 읽기 25 / 규칙 실험 25 / 증명 연결 25 / 최종 과제 짝 검토 35 / 정리 10. 목표는 제한된 자료형으로 모델을 표현하고, 그 interpreter가 실행과 증명의 공통 기준이 됨을 확인하는 것입니다.

## AST도 평범한 값입니다

[Protocol.lean](../Flightschool/Protocol.lean)의 `Guard`, `Action`, `Rule`을 읽습니다. AST는 “어떤 동작을 뜻하는지 기록한 자료”입니다. 별도 문법·parser·매크로·외부 DSL·code generation은 없습니다. `Rule`은 이벤트, guard, 명령 목록 세 필드만 가집니다.

```lean
⟨.timeout, .waiting, [.retry]⟩
```

이 값은 timeout이 오고 송신자가 대기 중이면 retry 명령을 적용한다는 뜻입니다. `evalGuard`가 조건을 계산하고 `execAction`이 명령 하나의 뜻을 구현합니다. `execActions`는 왼쪽부터 순서대로 적용합니다. `interpret`는 **첫 번째로 일치하는 규칙 하나**를 고릅니다. 모든 일치 규칙을 실행하지 않습니다. guard는 명령 실행 전 한 번 평가됩니다.

`step := interpret protocol`입니다. 반환형은 2회차와 같은 `State → Event → Option (State × List Action)`입니다. 여기서 Action 목록은 이미 적용한 명령 기록입니다. send/retry가 만드는 패킷은 반환 명령을 다시 실행하지 않아도 다음 State의 큐에 들어 있습니다.

## 실험하기

```sh
lake env lean exercises/Session4.lean
lake env lean projects/StopAndWait.lean
```

처음 시작 파일은 timeout 규칙이 없어 `none`을 출력합니다. 규칙 추가 후에는 `some`과 큐에 두 개의 data 0이 보입니다. 첫 start가 만든 data를 아직 전달하지 않았기 때문입니다.

두 개의 같은 event/guard 규칙을 넣으면 순서가 의미를 갖습니다. 예를 들어 start/idle에 빈 명령 목록을 가진 규칙을 먼저 두면 그 이벤트는 성공하지만 아무것도 보내지 않습니다. 이 경우에도 안전성은 유지될 수 있습니다. **안전성 정리만으로 원하는 진전까지 보장되지는 않습니다.**

## 증명을 연결하기

`actions_preserve`는 명령 목록에 대한 귀납, `interpret_preserves`는 규칙 목록에 대한 귀납입니다. 이 제한된 Action들은 모두 Inv를 보존하므로 어떤 규칙표에 대해서도 그 특정 불변식은 보존됩니다. 그렇다고 임의의 규칙표가 올바른 Stop-and-Wait는 아닙니다. 빈 규칙표도 안전하지만 아무것도 하지 않습니다. 새 Action 생성자를 추가하면 기존 case 분석과 보존 증명을 다시 완성해야 합니다.

`timeout_local`은 timeout에서 송신·수신 노드의 진행 번호가 바뀌지 않는 국소 보존 성질입니다. `Inv`는 한 상태의 불변식이고, `history_preserves`는 모든 trace prefix 상태의 불변식입니다. 최종 제출에서는 이 세 문장의 차이를 말로 설명합니다.

## 실습 E9–E11

[시작 파일](../exercises/Session4.lean)과 [최종 과제](../projects/README.md)를 사용합니다.

- **AST 설계 E9:** waiting일 때 timeout을 처리하는 규칙을 추가합니다. idle 상태 timeout은 여전히 거절되어야 합니다.
- **trace 설계 E10:** 첫 ACK를 복제해 하나로 전송을 끝내고 다음 패킷을 시작합니다. 남은 오래된 ACK는 다음 전송을 완료시키지 못해야 합니다. 마지막에는 2개 완료 상태여야 합니다.
- **증명 E11:** 다음 정리를 `intro`와 `history_preserves`로 증명합니다.

  ```lean
  theorem every_prefix (events : List Event) :
      ∀ s ∈ history {} events, Inv s := by
    intro s hs
    exact history_preserves events {} initial_inv s hs
  ```

  먼저 마지막 두 줄을 보지 않고 시도하세요. `∀ s ∈ ...`는 상태와 그 상태가 목록에 속한다는 가정을 차례로 받습니다.
- **설명:** `sender.next = 2`, `receiver.next = 0`인 상태는 Lean 값으로 쓸 수 있나요? 초기 상태에서 도달할 수 있나요? 해답의 `bad_unreachable`을 읽고 차이를 설명하세요.

## 단계별 힌트

1. E9: `⟨.timeout, .waiting, [.retry]⟩`를 규칙 목록에 넣습니다. Event와 Guard를 혼동하지 마세요.
2. E10: 첫 세 이벤트는 start, deliver, duplicate입니다. 큐에는 ACK 두 개가 남습니다.
3. E10: deliver, start 다음의 deliver는 오래된 ACK를 버리는 단계입니다. 그 직후 sender.next가 1인지 먼저 확인하세요.
4. E11: `history_preserves`에는 events, 초기 상태, 초기 Inv 증명, 상태, 소속 가정 순으로 인자를 줍니다.

## 해답과 해설

[해답](../solutions/Session4.lean)은 오래된 ACK가 다음 패킷을 완료시키지 않는 trace와 도달 불가능성 증명을 포함합니다. `intro eq`로 도달한다고 가정하고 `no_false_confirmation`에 그 등식을 대입하면 `2 ≤ 0`이라는 모순이 생깁니다.

[Traces.lean](../Flightschool/Traces.lean)의 `repeated_loss`는 임의의 유한 횟수만큼 재전송과 손실을 반복해도 대기 상태로 남음을 증명합니다. 무한 trace 자체를 형식화한 liveness 정리는 아닙니다. 영원히 손실만 일어나는 환경을 허용하면 eventual delivery를 주장할 수 없다는 설명의 근거입니다.

마지막으로 [보장의 구분](../references/semantics.md)을 읽고 최종 과제의 가정 문단을 작성하세요. 첫 주 필수 범위는 여기까지입니다.
