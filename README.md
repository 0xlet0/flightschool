# flightschool

Lean을 처음 접하는 프로그래머를 위한 **1주, 총 10시간** 네트워크 프로토콜 실습입니다. 작은 상태 머신을 실행한 다음, 같은 실행 의미론을 대상으로 안전성을 증명합니다. 함수형 프로그래밍·증명 보조기·특정 하드웨어 경험은 필요 없습니다. 함수, 조건문, 목록을 읽을 수 있으면 시작할 수 있습니다.

최종 결과는 두 노드, 명시적인 메시지 큐, ACK와 timeout을 갖춘 작은 Stop-and-Wait 모델입니다. 데이터·ACK 손실과 중복을 실행하고, 제한된 Lean AST의 interpreter 및 모든 유한 trace에 대한 불변식을 다룹니다.

## 설치부터 첫 실습까지

Lean **4.34.1**과 동봉된 Lake를 사용합니다. `lean-toolchain`에 정확한 버전을 고정했으며 Mathlib나 외부 Lean 패키지는 필요 없습니다. 공식 자료 확인일은 2026-10-03입니다. [출처와 버전 정책](references/sources.md)을 참고하세요.

1. Git, curl, VS Code를 설치합니다. Windows 사용자는 [공식 설치 안내](https://lean-lang.org/install/manual/)의 PowerShell 절차로 elan을 설치하세요. 아래 shell 명령은 Linux/macOS 기준입니다.
2. elan(Lean 버전 관리자)을 설치합니다. 이미 있다면 생략합니다.

   ```sh
   curl -sSfL https://elan.lean-lang.org/elan-init.sh -o /tmp/elan-init.sh
   sh /tmp/elan-init.sh -y --default-toolchain none
   . "$HOME/.elan/env"
   ```

3. 이 저장소를 내려받아 루트 디렉터리를 엽니다. 디렉터리 이름이 `flightschool`이라면 다음과 같습니다.

   ```sh
   cd flightschool
   lean --version
   lake --version
   lake build
   lake exe flightschool
   code --install-extension leanprover.lean4
   code .
   ```

   첫 명령에서 고정한 Lean 배포본을 내려받습니다. `lakefile.toml`이 보이는 폴더에서 실행해야 합니다. 이미 `/workspace`에 이 저장소가 열려 있다면 `cd /workspace`를 사용하세요. VS Code의 명령 팔레트에서 Lean Infoview를 열고, 오류 밑줄과 목표를 확인합니다.
4. [첫 수업](lessons/01-state.md)을 열고 다음을 실행합니다.

   ```sh
   lake env lean Flightschool/Basics.lean
   lake env lean exercises/Session1.lean
   ```

   첫 파일은 `waiting, sent = 1`과 `idle, sent = 1`을 출력합니다. 연습 파일의 `prediction`을 고친 뒤 다시 실행하세요. **연습 시작 파일도 컴파일되지만 과제를 이미 충족한 것은 아닙니다.** 예측값·빈 trace·의도적인 논리 버그를 요구사항에 맞게 수정하는 방식입니다.

전체 검증은 `bash scripts/check.sh`입니다(Python 3 필요). 기본 `lake build`에도 모든 수업 코드, 연습, 해답, 최종 과제가 포함됩니다. [검증 기록](references/validation.md)에 실제 검사 범위가 있습니다.

## 권장 1주 일정

| 날 | 활동 | 시간 | 완료 기준 |
|---|---|---:|---|
| 1 | 공동 1회: [환경과 상태](lessons/01-state.md) | 120분 | 상태 전이를 수정하고 실행 |
| 2 | E1–E2 복습 | 20분 | timeout 의미를 말로 설명 |
| 3 | 공동 2회: [실행과 첫 증명](lessons/02-execution.md) | 120분 | 잘못된 ACK 반례와 첫 정리 |
| 4 | E3–E5 복습 | 20분 | `Option` 거절 정책 구분 |
| 5 | 공동 3회: [네트워크와 불변식](lessons/03-network.md) | 120분 | 큐를 추적하고 trace 귀납 증명 |
| 6 | E6–E8 복습 | 20분 | 단계 보존과 전체 보존 연결 |
| 7 | 공동 4회: [AST와 프로토콜](lessons/04-ast.md) | 120분 | 규칙표 실행과 최종 과제 검토 |
| 7 | [최종 과제](projects/README.md) 정리·제출 | 60분 | 모델·trace·증명·가정 설명 |

총 600분입니다. 설치가 길어지면 1회차 개별 연습을 복습 시간으로 옮겨 8~12시간 안에 조정하세요. 처음부터 긴 보조 증명을 재현할 필요는 없습니다. 제공된 단계 보존 정리를 이용해 귀납 증명을 완성하는 것이 필수 범위입니다.

## 함께 배우는 방법

2~3명이 한 조가 되어 15분마다 입력자와 설명자를 바꿉니다. 실행 전에 각자 결과를 예상하고, Lean의 출력·목표와 비교합니다. 막히면 “현재 가정 / 목표 / 시도한 한 줄”을 공유합니다. 진행자는 정답을 외우는 대신 같은 절차를 따라갑니다. 7분 이상 막히면 힌트 한 단계, 15분이면 해답을 읽고 닫은 뒤 다시 작성합니다. [진행자 안내](instructors/guide.md)에 시간표와 오개념 대응이 있습니다.

## 저장소 지도

| 경로 | 용도 |
|---|---|
| `Flightschool/Basics.lean`, `Local.lean` | 1·2회차 작은 실행 예제 |
| `Flightschool/Protocol.lean` | 두 노드, 큐, AST, 명령 의미론, interpreter |
| `Flightschool/Invariants.lean` | 단계·trace·모든 중간 상태의 증명 |
| `Flightschool/Traces.lean`, `Main.lean` | 회귀 검사와 실행 로그 |
| `lessons/` | 목표·설명·실행·과제·단계별 힌트·해설 |
| `exercises/`, `solutions/` | 직접 수정하는 시작 파일과 컴파일되는 해답 |
| `projects/` | 최종 과제 명세와 검증된 참조 제출물 |
| `references/` | 문법·전술 요약, 의미론의 경계, 공식 출처 |
| `instructors/` | 초보 진행자용 운영·평가 안내 |

## 여기서 증명하는 것

`State × Event → Option (State × List Action)`을 Lean에서는 인자를 나누어 `State → Event → Option (State × List Action)`으로 씁니다. 성공한 규칙의 Action 목록은 이미 적용된 명령의 기록입니다. 호출자가 다시 적용하면 안 됩니다. `none`은 거절이고, trace 실행기는 이를 상태 유지로 처리합니다.

수신 번호는 실제로 받아들인 패킷 수, 송신 번호는 ACK로 확인한 패킷 수입니다. 어떤 유한 이벤트 목록에서도 `sender.next ≤ receiver.next ≤ sender.next + 1`이고 큐의 ACK는 실제 수신 이력을 근거로 합니다. 타입만으로는 잘못된 상태를 금지하지 않으며, 초기 상태에서 시작한다는 가정과 실행 의미론의 증명이 필요합니다.

이 모델은 무한히 증가하는 번호를 사용하며 비트가 순환하는 alternating-bit 프로토콜과 다릅니다. payload 내용, 실제 소켓·시계, 위조·손상·노드 장애, 임의 재정렬은 모델링하지 않습니다. 무한 손실에서는 안전해도 완료되지 않습니다. [모델의 가정과 보장](references/semantics.md)을 읽고 최종 과제에 경계를 적으세요.
