"""저장소 Lean 소스에서 증명 우회와 미완성 구멍을 검사합니다."""
from pathlib import Path
import re

root = Path(__file__).resolve().parent.parent
files = list(root.glob('*.lean'))
for folder in ('Flightschool', 'exercises', 'solutions', 'projects', 'scripts'):
    files.extend((root / folder).rglob('*.lean'))
# 이 과정은 사용자 공리나 커널 검증을 우회하는 증명을 허용하지 않습니다.
for path in sorted(files):
    source = path.read_text()
    if re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b', source):
        raise SystemExit(f'검토가 필요한 증명 우회: {path.relative_to(root)}')
print(f'Lean 소스 {len(files)}개: 미완성 증명·사용자 공리·검증 우회 없음')
