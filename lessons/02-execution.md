# 2회차 — 거절, 재전송, 첫 안전성

120분: 복습 10 / 실행 25 / 과제 40 / 첫 증명 30 / 정리 15. 목표는 `Option`, `List`, 재귀로 trace를 실행하고 잘못된 ACK를 받아들이지 않는 성질을 증명하는 것입니다.

## 계산해 보기

```sh
lake env lean Flightschool/Local.lean
lake env lean exercises/Session2.lean
```

[Local.lean](../Flightschool/Local.lean)은 `pending : Option Nat`으로 미확인 패킷을 저장합니다. `none`은 대기 패킷이 없음, `some 7`은 패킷 7의 ACK를 기다림입니다. 전이의 바깥쪽 `Option`은 다른 뜻입니다. `step s e = none`은 해당 이벤트를 받아들이지 않았다는 뜻입니다.

성공 시 `(다음 상태, 명령 목록)`을 반환합니다. `.transmit 7`은 관찰 가능한 전송 요청입니다. 이 단계에는 네트워크 큐가 없으며, 출력 Action을 실제 전송하는 런타임도 없습니다. 다음 수업에서 큐를 명시적으로 넣습니다.

```lean
#eval step ⟨some 7⟩ (.ack 6)  -- none
#eval step ⟨some 7⟩ .timeout -- 같은 pending과 transmit 7
#eval run {} [.send 7, .timeout, .ack 6, .ack 7]
```

`run`은 목록이 `[]`이면 현재 상태를 반환하고, `e :: es`이면 첫 이벤트를 적용하고 나머지를 재귀 실행합니다. `::`는 목록 앞에 항목을 붙입니다. `advance`는 거절된 이벤트에서 상태를 유지합니다. **거절을 전체 trace 실패로 해석하는 실행기도 가능하지만 이 저장소의 정책은 아닙니다.**

## 증명 읽기

`Prop`은 참·거짓을 말하는 명제의 타입입니다. `Bool` 값은 계산에 쓰고, 정리의 명제는 증명합니다. `n == k`는 Bool 비교, `n = k`는 Prop의 등식, `n ≠ k`는 그 부정입니다.

```lean
theorem pending_blocks_send (n k : Nat) :
    step ⟨some n⟩ (.send k) = none := by
  rfl
```

이는 모든 `n`, `k`에 대한 사실입니다. `rfl`은 계산상 같은 식에, `simp [step, h]`는 정의와 주어진 가정을 사용한 정리에 씁니다. `cases`는 가능한 경우를 모두 나눕니다. `timeout_preserves`에서는 구조체를 열고, pending이 none인지 some인지 나눕니다. Infoview를 한 줄씩 읽으세요.

## 실습 E3–E5

[시작 파일](../exercises/Session2.lean)에서 수행합니다.

- **완성 E3:** `recovery`를 send 7 → ACK 6 → timeout → ACK 7 순서로 만듭니다. 최종 pending은 none이어야 하고, 잘못된 ACK 직후에는 some 7이어야 합니다. 최종값만 확인하면 빈 trace도 통과하므로 중간값도 검사하세요.
- **디버깅 E4:** `buggyAck`는 왜 잘못됐나요? `some 7`, `ack 6` 반례를 재현하고 `advance`에 위임하거나 번호를 비교하도록 고치세요.
- **증명 E5:** 숫자 7에 대한 `example`을 모든 State `s`의 `advance s .timeout = s` 정리로 바꾸고 `cases`, `simp`로 증명하세요.

완료 검사:

```lean
#guard recovery = [.send 7, .ack 6, .timeout, .ack 7]
#guard run {} recovery = (⟨none⟩ : State)
#guard advance ⟨some 7⟩ (.ack 6) = (⟨some 7⟩ : State)
```

## 단계별 힌트

1. E3: 생성자 `.ack 6`도 이벤트 하나입니다. 목록에는 쉼표로 구분합니다.
2. E4: ACK의 번호를 버린 `_`가 핵심입니다. 상태를 지우기 전에 대기 번호와 비교해야 합니다.
3. E5: 먼저 `cases s with | mk p => ...`로 pending 필드에 이름을 붙입니다.
4. E5: `cases p <;> simp [advance, step]`로 두 경우를 처리합니다. `<;>`는 앞 전술이 만든 모든 목표에 뒤 전술을 적용합니다.

## 해답과 해설

[해답](../solutions/Session2.lean)은 ACK 6을 무시하고 timeout에 동일한 패킷 7을 재전송합니다. `wrong_ack`의 가정 `h : n ≠ k`는 번호가 다름을 이용하는 증명 자료입니다. 거절된 이벤트가 상태를 유지하는지는 `step`만으로 알 수 없으며, `advance` 정의까지 보아야 합니다.

`pending : Option Nat`은 동시에 두 pending을 저장할 수 없게 하지만 잘못된 ACK로 pending을 지우는 버그는 막지 못합니다. 데이터 타입의 보장과 프로토콜 의미의 보장을 구분하세요.
