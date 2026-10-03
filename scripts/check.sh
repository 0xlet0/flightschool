#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
lean --version
lake --version
python3 scripts/audit.py
lake build
lake exe flightschool
proof_log=$(mktemp)
trap 'rm -f "$proof_log"' EXIT
lake env lean scripts/Audit.lean > "$proof_log"
cat "$proof_log"
if grep -q 'sorryAx' "$proof_log"; then
  echo '미완성 증명 의존성이 발견되었습니다.' >&2
  exit 1
fi
echo '빌드, trace 실행 검사, 증명 감사 통과'
