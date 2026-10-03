import Flightschool.Protocol

namespace Flightschool

-- data는 송신자가 발급한 번호 이하, ACK는 이미 수신한 번호여야 합니다.
def ValidMessage (s : State) : Message → Prop
  | .data n => n ≤ s.sender.next
  | .ack n => n < s.receiver.next

def QueueValid (s : State) : Prop := ∀ m ∈ s.queue, ValidMessage s m

-- 전역 안전성의 핵심: 미확인 수신은 최대 하나입니다.
def Safe (s : State) : Prop :=
  s.sender.next ≤ s.receiver.next ∧ s.receiver.next ≤ s.sender.next + 1

def Inv (s : State) : Prop := Safe s ∧ QueueValid s

theorem initial_inv : Inv ({} : State) := by
  constructor
  · simp [Safe]
  · simp [QueueValid, ValidMessage]

-- 번호가 증가하면 기존 메시지의 정당성은 유지됩니다.
theorem valid_mono (s t : State) (hs : s.sender.next ≤ t.sender.next)
    (hr : s.receiver.next ≤ t.receiver.next) (m : Message)
    (h : ValidMessage s m) : ValidMessage t m := by
  cases m <;> simp only [ValidMessage] at * <;> omega

-- 아래 산술 분기는 제공되는 보조 증명입니다. 학습자는 먼저 문장과 분기를 읽습니다.
theorem action_preserves (s : State) (a : Action) (h : Inv s) :
    Inv (execAction s a) := by
  rcases h with ⟨⟨hlo, hhi⟩, hq⟩
  cases a with
  | send =>
    constructor
    · exact ⟨hlo, hhi⟩
    · intro m hm
      simp only [execAction, List.mem_append, List.mem_singleton] at hm
      rcases hm with hm | rfl
      · exact hq m hm
      · simp [execAction, ValidMessage]
  | retry =>
    constructor
    · exact ⟨hlo, hhi⟩
    · intro m hm
      simp only [execAction, List.mem_append, List.mem_singleton] at hm
      rcases hm with hm | rfl
      · exact hq m hm
      · simp [execAction, ValidMessage]
  | discard =>
    constructor
    · exact ⟨hlo, hhi⟩
    · intro m hm
      exact hq m (List.mem_of_mem_drop hm)
  | copy =>
    cases he : s.queue with
    | nil => simpa [execAction, he] using (show Inv s from ⟨⟨hlo, hhi⟩, hq⟩)
    | cons m ms =>
      simp only [execAction, he]
      constructor
      · exact ⟨hlo, hhi⟩
      · intro k hk
        apply hq k
        simpa [execAction, he, or_assoc, or_self] using hk
  | receiveData =>
    cases he : s.queue with
    | nil => simpa [execAction, he] using (show Inv s from ⟨⟨hlo, hhi⟩, hq⟩)
    | cons m ms =>
      cases m with
      | ack n => simpa [execAction, he] using (show Inv s from ⟨⟨hlo, hhi⟩, hq⟩)
      | data n =>
        have hn : n ≤ s.sender.next := hq (.data n) (by simp [he])
        have ht : ∀ m ∈ ms, ValidMessage s m := by
          intro m hm
          exact hq m (by simp [he, hm])
        by_cases eq : n = s.receiver.next
        · simp only [execAction, he, eq, beq_self_eq_true, ↓reduceIte]
          constructor
          · unfold Safe
            dsimp
            omega
          · intro m hm
            simp only [List.mem_append, List.mem_singleton] at hm
            rcases hm with hm | rfl
            · exact valid_mono s { s with receiver := ⟨s.receiver.next + 1⟩, queue := ms ++ [.ack s.receiver.next] }
                (Nat.le_refl _) (Nat.le_succ _) m (ht m hm)
            · simp [ValidMessage]
        · by_cases old : n < s.receiver.next
          · simp only [execAction, he, beq_eq_false_iff_ne.mpr eq, Bool.false_eq_true,
              ↓reduceIte, old]
            constructor
            · exact ⟨hlo, hhi⟩
            · intro m hm
              simp only [List.mem_append, List.mem_singleton] at hm
              rcases hm with hm | rfl
              · exact ht m hm
              · exact old
          · simp only [execAction, he, beq_eq_false_iff_ne.mpr eq, Bool.false_eq_true,
              ↓reduceIte, old]
            exact ⟨⟨hlo, hhi⟩, ht⟩
  | receiveAck =>
    cases he : s.queue with
    | nil => simpa [execAction, he] using (show Inv s from ⟨⟨hlo, hhi⟩, hq⟩)
    | cons m ms =>
      cases m with
      | data n => simpa [execAction, he] using (show Inv s from ⟨⟨hlo, hhi⟩, hq⟩)
      | ack n =>
        have hn : n < s.receiver.next := hq (.ack n) (by simp [he])
        have ht : ∀ m ∈ ms, ValidMessage s m := by
          intro m hm
          exact hq m (by simp [he, hm])
        by_cases yes : (s.sender.waiting && n == s.sender.next) = true
        · have both : s.sender.waiting = true ∧ n = s.sender.next := by simpa using yes
          have eq := both.2
          simp only [execAction, he, yes, ↓reduceIte]
          constructor
          · unfold Safe
            dsimp
            omega
          · intro m hm
            exact valid_mono s { s with sender := ⟨s.sender.next + 1, false⟩, queue := ms }
              (Nat.le_succ _) (Nat.le_refl _) m (ht m hm)
        · simpa [execAction, he, yes] using
            (show Inv { s with queue := ms } from ⟨⟨hlo, hhi⟩, ht⟩)

theorem actions_preserve (as : List Action) (s : State) (h : Inv s) :
    Inv (execActions s as) := by
  induction as generalizing s with
  | nil => exact h
  | cons a rest ih =>
    apply ih
    exact action_preserves s a h

-- 임의의 규칙 목록도 이 제한된 명령 집합의 불변식을 보존합니다.
theorem interpret_preserves (rules : List Rule) (s t : State) (e : Event)
    (as : List Action) (h : Inv s) (result : interpret rules s e = some (t, as)) :
    Inv t := by
  induction rules with
  | nil => simp [interpret] at result
  | cons r rest ih =>
    simp only [interpret] at result
    split at result
    · cases result
      exact actions_preserve r.actions s h
    · exact ih result

theorem step_preserves (s t : State) (e : Event) (as : List Action)
    (h : Inv s) (result : step s e = some (t, as)) : Inv t := by
  exact interpret_preserves protocol s t e as h result

theorem advance_preserves (s : State) (e : Event) (h : Inv s) : Inv (advance s e) := by
  unfold advance
  cases result : step s e with
  | none => exact h
  | some pair => exact step_preserves s pair.1 e pair.2 h result

theorem run_preserves (es : List Event) (s : State) (h : Inv s) : Inv (run s es) := by
  induction es generalizing s with
  | nil => exact h
  | cons e es ih =>
    apply ih
    exact advance_preserves s e h

theorem history_preserves (es : List Event) (s : State) (h : Inv s) :
    ∀ t ∈ history s es, Inv t := by
  induction es generalizing s with
  | nil => simpa [history] using h
  | cons e es ih =>
    intro t ht
    simp only [history, List.mem_cons] at ht
    rcases ht with rfl | ht
    · exact h
    · exact ih (advance s e) (advance_preserves s e h) t ht

-- ACK를 위조하여 sender만 앞서게 만드는 상태에는 도달할 수 없습니다.
theorem no_false_confirmation (es : List Event) :
    (run {} es).sender.next ≤ (run {} es).receiver.next := by
  exact (run_preserves es {} initial_inv).1.1

-- 수신자가 두 개 이상 앞서는 상태에도 도달할 수 없습니다.
theorem no_receiver_overrun (es : List Event) :
    ¬ (run {} es).sender.next + 1 < (run {} es).receiver.next := by
  have h := (run_preserves es {} initial_inv).1.2
  omega

end Flightschool
