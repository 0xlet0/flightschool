import Flightschool.Traces

open Flightschool

def main : IO Unit := do
  for (name, events) in scenarios do
    IO.println s!"\n[{name}]"
    let final ← simulate {} events
    IO.println s!"  최종: {summary final}"
  IO.println "\n모든 예제의 예상 결과는 Traces.lean의 #guard로 빌드할 때 검사합니다."
