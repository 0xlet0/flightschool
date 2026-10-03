# 1회차 — 상태를 값으로 만들기

120분: 설치 25 / 읽기·실행 25 / 수정 35 / 짝 설명 20 / 정리 15. 목표는 `#check`와 `#eval`을 구별하고, 상태·이벤트·전이를 직접 수정하는 것입니다.

## 먼저 실행하기

```sh
lake build
lake env lean Flightschool/Basics.lean
```

`#check step`은 함수의 타입을, `#eval step {} .send`는 계산한 값을 보여 줍니다. `State → Event → State`는 상태와 이벤트를 받아 다음 상태를 돌려주는 함수입니다. `{}`는 필드의 기본값으로 만든 상태입니다.

[실행 코드](../Flightschool/Basics.lean)에는 `Phase`라는 선택지와 `State`라는 묶음이 있습니다. `inductive`는 가능한 경우를 나열하고, `structure`는 함께 저장할 필드를 정합니다. `.idle`은 문맥으로 타입을 알 때 `Phase.idle`을 짧게 쓰는 표기입니다. `Nat`은 0부터 시작하는 자연수입니다.

```lean
#eval step {} .send
#eval step (step {} .send) .ack
```

첫 결과는 `waiting, 1`, 다음 결과는 `idle, 1`입니다. ACK가 와도 보낸 횟수는 감소하지 않습니다. `{ s with phase := .idle }`은 `s`의 다른 필드를 유지한 새 값을 만듭니다. Lean의 함수는 입력 객체를 직접 변경하지 않습니다. 패턴 매칭의 `| _, _ => s`는 앞에서 처리하지 않은 모든 경우를 뜻합니다.

`theorem idle_timeout`은 어떤 자연수 `n`에서도 성립합니다. `:= by rfl`은 양쪽을 계산했을 때 같다는 증명입니다. 아직 전술을 외우지 말고 `n`을 0, 3으로 바꾸어 손으로 계산해 보세요.

## 실습 E1–E2

[시작 파일](../exercises/Session1.lean)을 수정합니다.

1. **읽기·예측 E1:** 실행 전에 `prediction`을 예상 phase로 바꿉니다. send를 두 번 하면 `sent`는 얼마인지 설명하세요.
2. **수정 E2:** `retryStep`에서 waiting 상태의 timeout만 전송 시도 횟수를 1 늘리게 하세요. idle timeout은 그대로입니다. `sent`는 이 연습에서 전송 시도 수입니다. 최종 모델의 `sender.next`는 ACK 완료 수이므로 의미가 다릅니다.
3. **디버깅:** 함수 선언의 반환 타입을 잠시 `Nat`으로 바꾸어 오류를 읽고 복구하세요. 실행 결과 오류와 타입 오류의 차이를 짝에게 설명합니다.

완료 검사로 E2 파일에 다음을 붙여 실행하세요.

```lean
#guard (retryStep ⟨.waiting, 1⟩ .timeout).sent = 2
#guard (retryStep ⟨.idle, 1⟩ .timeout).sent = 1
```

`#guard`는 이번 구체적인 계산이 맞는지 확인합니다. 오류 실험은 복구한 뒤 빌드합니다.

## 단계별 힌트

- E1 힌트 1: `step`에서 `.idle, .send`에 맞는 줄을 찾습니다.
- E1 힌트 2: 두 번째 send는 현재 phase가 waiting이어서 마지막 줄에 맞습니다.
- E2 힌트 1: `match s.phase, e with`로 경우를 나눕니다.
- E2 힌트 2: `.waiting, .timeout`에서 `{ s with sent := s.sent + 1 }`을 반환합니다.
- E2 힌트 3: 나머지 경우는 `step s e`에 맡깁니다. 모든 분기가 State를 반환해야 합니다.

## 해답과 해설

[검증된 해답](../solutions/Session1.lean)을 열고 비교하세요. E1은 `.waiting`, 두 번 send해도 `sent = 1`입니다. E2는 timeout 분기만 추가합니다. `retryStep`의 `#guard` 두 개는 정상·경계 입력을 검사하지만 모든 입력을 증명하지 않습니다. 다음 회차에서 `Nat` 변수와 모든 상태를 다루는 정리를 씁니다.

종료 질문: “상태를 바꾼다”는 말이 이 코드에서는 무엇을 반환한다는 뜻인가요? 설명이 어려우면 `s`와 결과값을 나란히 써 보세요.
