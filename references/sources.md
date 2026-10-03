# 공식 자료와 버전 고정

2026-10-03에 아래 공식 자료를 확인했습니다. 저장소는 확인 당시 공식 최신 안정 릴리스 **Lean v4.34.1**을 사용하며 `lean-toolchain`에 `leanprover/lean4:v4.34.1`로 고정합니다. Lean과 함께 배포되는 Lake를 사용합니다. 외부 Lean 의존성은 없습니다.

- [Lean 4.34.1 공식 릴리스](https://github.com/leanprover/lean4/releases/tag/v4.34.1): 선택한 배포 버전. latest 주소가 이 태그로 연결되는 것을 확인했습니다.
- [공식 설치 안내](https://lean-lang.org/install/manual/): elan 및 VS Code Lean 4 확장 설치. OS별 설치 오류는 여기에서 확인합니다.
- [Elan과 toolchain 관리](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Managing-Toolchains-with-Elan/): 프로젝트별 정확한 버전 고정 방식.
- [Lake 공식 문서](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/): 라이브러리와 실행 파일의 빌드 도구.
- [Lean 언어 참고서](https://lean-lang.org/doc/reference/latest/): 필요할 때 문법·명령을 찾아보는 공식 참고서. 첫 주에 통독하지 않습니다.

latest 문서는 나중에 바뀔 수 있습니다. 이 과정의 호환성 기준은 고정 버전과 실제 `lake build` 결과입니다. 버전 갱신 시 toolchain만 바꾸고 끝내지 말고 `bash scripts/check.sh`를 다시 실행하세요. Mathlib나 `lake exe cache get`은 필요하지 않습니다.
