------------------------------------------------------------------------
-- The Agda standard library
--
-- Properties of Rational numbers
------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

module Data.Rational.Properties where

open import Function using (_∘_ ; _$_)
open import Data.Integer as ℤ using (ℤ; ∣_∣; +_; -[1+_])
open import Data.Integer.Coprimality using (coprime-divisor)
import Data.Integer.Properties as ℤ
open import Data.Rational.Base
open import Data.Nat as ℕ using (ℕ; zero; suc)
import Data.Nat.Properties as ℕ
open import Data.Nat.Coprimality as C using (Coprime; coprime?)
open import Data.Nat.Divisibility hiding (/-cong)
open import Data.Product using (_,_)
open import Data.Sum
open import Level using (0ℓ)
open import Relation.Binary
open import Relation.Binary.PropositionalEquality
open import Relation.Nullary using (Dec; yes; no; recompute)
open import Relation.Nullary.Decidable as Dec′ using (True; fromWitness)

open import Algebra.FunctionProperties {A = ℚ} _≡_
open import Algebra.FunctionProperties.Consequences.Propositional

------------------------------------------------------------------------
-- Helper lemmas

private
  recomputeCP : ∀ {n d} → .(Coprime n (suc d)) → Coprime n (suc d)
  recomputeCP {n} {d-1} c = recompute (coprime? n (suc d-1)) c

------------------------------------------------------------------------
-- Propositional equality

infix 4 _≟_

_≟_ : Decidable {A = ℚ} _≡_
mkℚ n₁ d₁ _ ≟ mkℚ n₂ d₂ _ with n₁ ℤ.≟ n₂ | d₁ ℕ.≟ d₂
... | yes refl | yes refl = yes refl
... | no n₁≢n₂ | _        = no λ { refl → n₁≢n₂ refl }
... | _        | no d₁≢d₂ = no λ { refl → d₁≢d₂ refl }

≡-setoid : Setoid 0ℓ 0ℓ
≡-setoid = setoid ℚ

≡-decSetoid : DecSetoid 0ℓ 0ℓ
≡-decSetoid = decSetoid _≟_

------------------------------------------------------------------------
-- Numerator and denominator equality

≡⇒≃ : _≡_ ⇒ _≃_
≡⇒≃ refl = refl

≃⇒≡ : _≃_ ⇒ _≡_
≃⇒≡ {i = mkℚ n₁ d₁ c₁} {j = mkℚ n₂ d₂ c₂} eq = helper
  where
  open ≡-Reasoning

  1+d₁∣1+d₂ : suc d₁ ∣ suc d₂
  1+d₁∣1+d₂ = coprime-divisor (+ suc d₁) n₁ (+ suc d₂)
    (C.sym (recomputeCP c₁)) $
    divides ∣ n₂ ∣ $ begin
      ∣ n₁ ℤ.* + suc d₂ ∣  ≡⟨ cong ∣_∣ eq ⟩
      ∣ n₂ ℤ.* + suc d₁ ∣  ≡⟨ ℤ.abs-*-commute n₂ (+ suc d₁) ⟩
      ∣ n₂ ∣ ℕ.* suc d₁    ∎

  1+d₂∣1+d₁ : suc d₂ ∣ suc d₁
  1+d₂∣1+d₁ = coprime-divisor (+ suc d₂) n₂ (+ suc d₁)
    (C.sym (recomputeCP c₂)) $
    divides ∣ n₁ ∣ (begin
      ∣ n₂ ℤ.* + suc d₁ ∣  ≡⟨ cong ∣_∣ (sym eq) ⟩
      ∣ n₁ ℤ.* + suc d₂ ∣  ≡⟨ ℤ.abs-*-commute n₁ (+ suc d₂) ⟩
      ∣ n₁ ∣ ℕ.* suc d₂    ∎)

  helper : mkℚ n₁ d₁ c₁ ≡ mkℚ n₂ d₂ c₂
  helper with ∣-antisym 1+d₁∣1+d₂ 1+d₂∣1+d₁
  ... | refl with ℤ.*-cancelʳ-≡ n₁ n₂ (+ suc d₁) (λ ()) eq
  ...   | refl = refl

------------------------------------------------------------------------
-- _≤_

infix 4 _≤?_

drop-*≤* : ∀ {p q} → p ≤ q → (↥ p ℤ.* ↧ q) ℤ.≤ (↥ q ℤ.* ↧ p)
drop-*≤* (*≤* pq≤qp) = pq≤qp

≤-reflexive : _≡_ ⇒ _≤_
≤-reflexive refl = *≤* ℤ.≤-refl

≤-refl : Reflexive _≤_
≤-refl = ≤-reflexive refl

≤-trans : Transitive _≤_
≤-trans {i = p@(mkℚ n₁ d₁ c₁)} {j = q@(mkℚ n₂ d₂ c₂)} {k = r@(mkℚ n₃ d₃ c₃)} (*≤* eq₁) (*≤* eq₂)
  = *≤* $ ℤ.*-cancelʳ-≤-pos (n₁ ℤ.* ℤ.+ suc d₃) (n₃ ℤ.* ℤ.+ suc d₁) d₂ $ begin
  let sd₁ = ↧ p; sd₂ = ↧ q; sd₃ = ↧ r in
  (n₁  ℤ.* sd₃) ℤ.* sd₂  ≡⟨ ℤ.*-assoc n₁ sd₃ sd₂ ⟩
  n₁   ℤ.* (sd₃ ℤ.* sd₂) ≡⟨ cong (n₁ ℤ.*_) (ℤ.*-comm sd₃ sd₂) ⟩
  n₁   ℤ.* (sd₂ ℤ.* sd₃) ≡⟨ sym (ℤ.*-assoc n₁ sd₂ sd₃) ⟩
  (n₁  ℤ.* sd₂) ℤ.* sd₃  ≤⟨ ℤ.*-monoʳ-≤-pos d₃ eq₁ ⟩
  (n₂  ℤ.* sd₁) ℤ.* sd₃  ≡⟨ cong (ℤ._* sd₃) (ℤ.*-comm n₂ sd₁) ⟩
  (sd₁ ℤ.* n₂)  ℤ.* sd₃  ≡⟨ ℤ.*-assoc sd₁ n₂ sd₃ ⟩
  sd₁  ℤ.* (n₂  ℤ.* sd₃) ≤⟨ ℤ.*-monoˡ-≤-pos d₁ eq₂ ⟩
  sd₁  ℤ.* (n₃  ℤ.* sd₂) ≡⟨ sym (ℤ.*-assoc sd₁ n₃ sd₂) ⟩
  (sd₁ ℤ.* n₃)  ℤ.* sd₂  ≡⟨ cong (ℤ._* sd₂) (ℤ.*-comm sd₁ n₃) ⟩
  (n₃  ℤ.* sd₁) ℤ.* sd₂  ∎
  where open ℤ.≤-Reasoning

≤-antisym : Antisymmetric _≡_ _≤_
≤-antisym (*≤* le₁) (*≤* le₂) = ≃⇒≡ (ℤ.≤-antisym le₁ le₂)

≤-total : Total _≤_
≤-total p q = [ inj₁ ∘ *≤* , inj₂ ∘ *≤* ]′ (ℤ.≤-total
  (↥ p ℤ.* ↧ q)
  (↥ q ℤ.* ↧ p))

_≤?_ : Decidable _≤_
p ≤? q = Dec′.map′ *≤* drop-*≤* ((↥ p ℤ.* ↧ q) ℤ.≤? (↥ q ℤ.* ↧ p))

≤-isPreorder : IsPreorder _≡_ _≤_
≤-isPreorder = record
  { isEquivalence = isEquivalence
  ; reflexive     = ≤-reflexive
  ; trans         = ≤-trans
  }

≤-isPartialOrder : IsPartialOrder _≡_ _≤_
≤-isPartialOrder = record
  { isPreorder = ≤-isPreorder
  ; antisym    = ≤-antisym
  }

≤-isTotalOrder : IsTotalOrder _≡_ _≤_
≤-isTotalOrder = record
  { isPartialOrder = ≤-isPartialOrder
  ; total          = ≤-total
  }

≤-isDecTotalOrder : IsDecTotalOrder _≡_ _≤_
≤-isDecTotalOrder = record
  { isTotalOrder = ≤-isTotalOrder
  ; _≟_          = _≟_
  ; _≤?_         = _≤?_
  }

≤-decTotalOrder : DecTotalOrder _ _ _
≤-decTotalOrder = record
  { Carrier         = ℚ
  ; _≈_             = _≡_
  ; _≤_             = _≤_
  ; isDecTotalOrder = ≤-isDecTotalOrder
  }

≤-irrelevant : Irrelevant _≤_
≤-irrelevant (*≤* x₁) (*≤* x₂) = cong *≤* (ℤ.≤-irrelevant x₁ x₂)

------------------------------------------------------------------------
-- DEPRECATED NAMES
------------------------------------------------------------------------
-- Please use the new names as continuing support for the old names is
-- not guaranteed.

-- Version 1.0

≤-irrelevance = ≤-irrelevant
{-# WARNING_ON_USAGE ≤-irrelevance
"Warning: ≤-irrelevance was deprecated in v1.0.
Please use ≤-irrelevant instead."
#-}
