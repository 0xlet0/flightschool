import Flightschool.Local
namespace Solutions.Session2
open Flightschool.Local

def recovery : List Event := [.send 7, .ack 6, .timeout, .ack 7]
#guard recovery = [.send 7, .ack 6, .timeout, .ack 7]
#guard run {} recovery = (⟨none⟩ : State)
#guard advance ⟨some 7⟩ (.ack 6) = (⟨some 7⟩ : State)

def fixedAck (s : State) (e : Event) : State := advance s e
#guard fixedAck ⟨some 7⟩ (.ack 6) = (⟨some 7⟩ : State)

theorem timeout_keeps_pending (s : State) : advance s .timeout = s := by
  cases s with
  | mk p => cases p <;> simp [advance, step]
end Solutions.Session2
