import Flightschool.Invariants
namespace Solutions.Session3
open Flightschool

def ackLoss : List Event := [.start, .deliver, .drop, .timeout, .deliver, .deliver]
#guard (run {} ackLoss).sender.next = 1
#guard (run {} ackLoss).receiver.next = 1

theorem safe_parts (s : State) (h : Inv s) : Safe s := by
  constructor
  · exact h.1.1
  · exact h.1.2

theorem all_events_preserve (es : List Event) (s : State) (h : Inv s) : Inv (run s es) := by
  induction es generalizing s with
  | nil => exact h
  | cons e es ih =>
    apply ih
    exact advance_preserves s e h
end Solutions.Session3
