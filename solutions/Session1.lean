import Flightschool.Basics
namespace Solutions.Session1
open Flightschool.Basics

def prediction : Phase := .waiting

def retryStep (s : State) (e : Event) : State :=
  match s.phase, e with
  | .waiting, .timeout => { s with sent := s.sent + 1 }
  | _, _ => step s e

#guard prediction = (step {} .send).phase
#guard (retryStep ⟨.waiting, 1⟩ .timeout).sent = 2
#guard (retryStep ⟨.idle, 1⟩ .timeout).sent = 1
end Solutions.Session1
