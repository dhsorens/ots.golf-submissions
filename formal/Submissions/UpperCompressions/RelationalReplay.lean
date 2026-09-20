import Submissions.UpperCompressions.ProofBundle11

/-!
Generic algebra for replay when a selected source class can authenticate more
than one cached target class.  This file deliberately stops before the
schedule-specific incidence concentration certificates.
-/

noncomputable section
open scoped BigOperators Classical

namespace WeightedRelationalReplay

variable {I : Type*} [Fintype I] [DecidableEq I]

/-- Winner mass aggregated backwards through a source-to-target relation. -/
def reverseWeight (compat : I → I → Prop) [DecidableRel compat]
    (q : I → ℝ) (t : I) : ℝ :=
  ∑ s, if compat s t then q s else 0

/-- Raw target mass reachable from one source. -/
def forwardMass (compat : I → I → Prop) [DecidableRel compat]
    (p : I → ℝ) (s : I) : ℝ :=
  ∑ t, if compat s t then p t else 0

/-- A fresh selected source may use any already-seen compatible target. -/
def freshReplay (compat : I → I → Prop) [DecidableRel compat]
    (global : I → ℕ) (s : I) : ℝ :=
  ∑ t, if compat s t ∧ 1 ≤ global t then 1 else 0

/-- A cached selected occurrence cannot use itself.  Its self target therefore
needs multiplicity two; every strict compatible target needs multiplicity one. -/
def knownReplay (compat : I → I → Prop) [DecidableRel compat]
    (global : I → ℕ) (s : I) : ℝ :=
  ∑ t, if compat s t ∧ (if t = s then 2 ≤ global t else 1 ≤ global t) then 1 else 0

/-- Target-oriented form of the fresh replay term. -/
def seen (compat : I → I → Prop) [DecidableRel compat]
    (q : I → ℝ) (global : I → ℕ) : ℝ :=
  ∑ t, (if 1 ≤ global t then reverseWeight compat q t else 0)

/-- Source-weighted cached term.  It is bilinear in row multiplicities and
global target occupancy and must not be replaced by a scalar reverse weight. -/
def bad (compat : I → I → Prop) [DecidableRel compat]
    (p q : I → ℝ) (global row : I → ℕ) : ℝ :=
  ∑ s, (row s : ℝ) * (q s / p s) * knownReplay compat global s

/-- Exact replay potential before application of the selector kernel envelope. -/
def hazard (compat : I → I → Prop) [DecidableRel compat]
    (p q : I → ℝ) (N : ℝ) (n : ℕ) (global row : I → ℕ) : ℝ :=
  (1 - (n : ℝ) / N) * (∑ s, q s * freshReplay compat global s) +
    bad compat p q global row / N

/-- Reverse and forward presentations of the fresh term agree. -/
theorem fresh_eq_seen (compat : I → I → Prop) [DecidableRel compat]
    (q : I → ℝ) (global : I → ℕ) :
    (∑ s, q s * freshReplay compat global s) = seen compat q global := by
  unfold freshReplay seen reverseWeight
  calc
    (∑ s, q s * ∑ t, if compat s t ∧ 1 ≤ global t then 1 else 0) =
        ∑ s, ∑ t, if compat s t ∧ 1 ≤ global t then q s else 0 := by
          apply Finset.sum_congr rfl
          intro s _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro t _
          split_ifs <;> ring
    _ = ∑ t, ∑ s, if compat s t ∧ 1 ≤ global t then q s else 0 := by
          rw [Finset.sum_comm]
    _ = ∑ t, if 1 ≤ global t then (∑ s, if compat s t then q s else 0) else 0 := by
          apply Finset.sum_congr rfl
          intro t _
          by_cases ht : 1 ≤ global t
          · rw [if_pos ht]
            apply Finset.sum_congr rfl
            intro s _
            by_cases hs : compat s t <;> simp [ht, hs]
          · rw [if_neg ht]
            apply Finset.sum_eq_zero
            intro s _
            simp [ht]
    _ = _ := rfl

/-- The common schedule mean may be computed in either orientation. -/
theorem reverse_mean (compat : I → I → Prop) [DecidableRel compat]
    (p q : I → ℝ) :
    (∑ t, p t * reverseWeight compat q t) =
      ∑ s, q s * forwardMass compat p s := by
  unfold reverseWeight forwardMass
  calc
    (∑ t, p t * ∑ s, if compat s t then q s else 0) =
        ∑ t, ∑ s, if compat s t then p t * q s else 0 := by
          apply Finset.sum_congr rfl
          intro t _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro s _
          split_ifs <;> ring
    _ = ∑ s, ∑ t, if compat s t then p t * q s else 0 := by
          rw [Finset.sum_comm]
    _ = ∑ s, q s * ∑ t, if compat s t then p t else 0 := by
          apply Finset.sum_congr rfl
          intro s _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro t _
          split_ifs <;> ring

section Completion

open WeightedCompletion

variable {Ω D : Type*} [Fintype Ω] [Nonempty Ω]
  [Fintype D] [Nonempty D] [DecidableEq D]

/-- Reuse the accepted completed-row payoff, but keep the winner weight on the
source and put the compatibility relation in its replay score. -/
def referencePayoff (R : Finset D) (table : Ω → D → Option I)
    (p q : I → ℝ) (compat : I → I → Prop) [DecidableRel compat]
    (global : I → ℕ) (ω : Ω) : ℝ :=
  WeightedCompletion.referencePayoff R table p q
    (knownReplay compat global) (freshReplay compat global) ω

/-- Exact completed-row mean.  The exposed part remains source-weighted; only
the fresh part can subsequently be rewritten with `reverseWeight`. -/
theorem referencePayoff_mean (R : Finset D) (fixed : D → Option I)
    (table : Ω → D → Option I) (p q : I → ℝ)
    (compat : I → I → Prop) [DecidableRel compat] (global : I → ℕ)
    (hp : ∀ i, 0 < p i)
    (hknown : ∀ ω a, a ∈ R → table ω a = fixed a)
    (hfresh : ∀ a, a ∉ R → ∀ i,
      WeightedReplacement.uniformMean
        (fun ω => if table ω a = some i then 1 else 0) = p i) :
    WeightedReplacement.uniformMean
        (referencePayoff R table p q compat global) =
      hazard compat p q (Fintype.card D : ℝ) R.card global
        (WeightedCompletion.rowCount R fixed) := by
  unfold referencePayoff
  rw [WeightedCompletion.referencePayoff_mean R fixed table p q
    (knownReplay compat global) (freshReplay compat global) hp hknown hfresh]
  unfold hazard bad
  ring

end Completion

/-! The following scalar identities isolate the leave-one-out bookkeeping from
the later class-by-class bump lemmas. -/

def potential (N n seenValue badValue : ℝ) : ℝ :=
  (1 - n / N) * seenValue + badValue / N

theorem potential_change_outside (N n S B dS dB : ℝ) :
    potential N n (S + dS) (B + dB) - potential N n S B =
      (1 - n / N) * dS + dB / N := by
  unfold potential
  ring

theorem potential_change_inside (N n S B dS dB : ℝ) :
    potential N (n + 1) (S + dS) (B + dB) - potential N n S B =
      (1 - (n + 1) / N) * dS + dB / N - S / N := by
  unfold potential
  ring

/-- The expected new-source contribution cancels the negative row-size shift. -/
theorem inside_source_cancel (N S sourceMean remainder : ℝ)
    (hsource : sourceMean = S) :
    -S / N + sourceMean / N + remainder / N = remainder / N := by
  rw [hsource]
  ring

/-- Strict reverse score used by an existing row when a target first appears. -/
def reverseStrict (compat : I → I → Prop) [DecidableRel compat]
    (w : I → ℝ) (row : I → ℕ) (t : I) : ℝ :=
  ∑ s, if s ≠ t ∧ compat s t then (row s : ℝ) * w s else 0

/-- Strict forward score contributed by a newly added source occurrence. -/
def forwardStrict (compat : I → I → Prop) [DecidableRel compat]
    (w : I → ℝ) (global : I → ℕ) (s : I) : ℝ :=
  w s * ∑ t, if t ≠ s ∧ compat s t ∧ 1 ≤ global t then 1 else 0

section Posterior

open WeightedReplacement

/-- One-sided variant of the accepted Bayes lemma.  Compatible targets below
the selected tier reduce its winning likelihood, so equality on the target set
is unnecessarily strong. -/
theorem finiteLikelihoodJointLE {Ω : Type*} [Fintype Ω]
    (weight likelihood : Ω → ℝ) (target survival : Ω → Prop) (c : ℝ)
    (hw : ∀ y, 0 ≤ weight y) (hl : ∀ y, 0 ≤ likelihood y)
    (ht : ∀ y, target y → likelihood y ≤ c)
    (hs : ∀ y, survival y → c ≤ likelihood y)
    (hmass : 0 < WeightedReplacement.weightedMass weight survival) :
    (∑ y, if target y then weight y * likelihood y else 0) ≤
      (WeightedReplacement.weightedMass weight target /
        WeightedReplacement.weightedMass weight survival) *
        ∑ y, weight y * likelihood y := by
  have hnum : (∑ y, if target y then weight y * likelihood y else 0) ≤
      WeightedReplacement.weightedMass weight target * c := by
    unfold WeightedReplacement.weightedMass
    rw [Finset.sum_mul]
    apply Finset.sum_le_sum
    intro y _
    by_cases hy : target y
    · simp only [if_pos hy]
      exact mul_le_mul_of_nonneg_left (ht y hy) (hw y)
    · simp only [if_neg hy, zero_mul]
  have hlow : WeightedReplacement.weightedMass weight survival * c ≤
      ∑ y, weight y * likelihood y := by
    unfold WeightedReplacement.weightedMass
    rw [Finset.sum_mul]
    apply Finset.sum_le_sum
    intro y _
    by_cases hy : survival y
    · simp only [if_pos hy]
      exact mul_le_mul_of_nonneg_left (hs y hy) (hw y)
    · simp only [if_neg hy, zero_mul]
      exact mul_nonneg (hw y) (hl y)
  have hc : c ≤ (∑ y, weight y * likelihood y) /
      WeightedReplacement.weightedMass weight survival := by
    apply (le_div_iff₀ hmass).2
    simpa only [mul_comm] using hlow
  calc
    _ ≤ WeightedReplacement.weightedMass weight target * c := hnum
    _ ≤ WeightedReplacement.weightedMass weight target *
        ((∑ y, weight y * likelihood y) /
          WeightedReplacement.weightedMass weight survival) :=
      mul_le_mul_of_nonneg_left hc
        (WeightedReplacement.weightedMass_nonneg weight target hw)
    _ = _ := by
      field_simp [ne_of_gt hmass] <;> ring

/-- An answer which is not strictly worse than the selected source has
likelihood at most the equal-tier value.  Strict compatible predecessors satisfy
this premise and therefore cannot increase the posterior. -/
theorem coordinateLikelihood_le_same {Ω : Type*} (L : ℕ)
    (A B delta N : ℝ) (weak strict : Ω → Prop)
    (hA : 0 ≤ A) (hB : 0 ≤ B) (hdelta : 0 ≤ delta) (hN : 0 ≤ N)
    (y : Ω) (hstrict : ¬ strict y) :
    WeightedReplacement.coordinateLikelihood L A B delta N weak strict y ≤
      WeightedReplacement.kernel L (A + delta) B / N := by
  unfold WeightedReplacement.coordinateLikelihood
  rw [if_neg hstrict]
  apply div_le_div_of_nonneg_right _ hN
  apply WeightedReplacement.kernel_mono L
  · split_ifs <;> linarith
  · exact hB
  · split_ifs <;> linarith
  · exact le_rfl

end Posterior

end WeightedRelationalReplay
