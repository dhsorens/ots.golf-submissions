# Verified 92: weighted minimum selection over disclosure cuts

This construction has a Lean-checked verifier bound of 92 hash compressions on
every raw input and every oracle-answer path, together with the exact contract's
raw-signature admissibility and strong-security theorems. The hosted verifier
accepted 92 as a new record in 318.7 seconds, improving the previous 100.
The [durable verdict](https://github.com/leanEthereum/ots.golf-submissions/pull/8#issuecomment-5747949677)
retains the original checked source `7be6d31b9de82713e5b088f17e62e30a9198a734`.

Later sections retain the research sequence. The final checkpoint records the
rejection of the 89-compression prototype by a pre-sign replay counterexample;
none of the follow-up experiments changes the verified claim of 92.

The construction combines a compact disclosure forest with an uneven
distribution over its admissible cuts. Signing searches for a low-tier cut;
verification recomputes only the path from that cut to the public key.

## Where the eight compressions come from

The graph has 54 tagged chains of length 18, grouped into 18 ternary hashes and
one root. Each disclosed value has 129 bits. A signature reveals six group
values and one value on each of the other 36 chains, for 42 values total.
The remaining chain lengths sum to 74. Verification therefore costs

```
74 chain compressions + 12 group compressions + 5 root compressions
  + 1 message/nonce index compression = 92.
```

Key generation costs `54*18 + 18 + 5 = 995` compressions. The wire format uses
an 86-bit nonce and `42*129` disclosure bits, exactly the 5504-bit limit. The
cost theorem quantifies over arbitrary raw signatures, including rejecting
inputs. All pure computation follows the compression track's cost model; this
is not a cycle-count claim.

## Weighted classes and the exact sampler

The cut family is large enough for 770731564938763476110450815401984 distinct
classes. The decoder places them in 72 tiers. Tier `j` has `19*2^(104-j)` classes
for `j<71`, with `91*2^33` classes in the last tier. Each class in tier `j`
receives `2^(j+1)` accepted aliases in the low 129 bits of the hash output.
The total accepted mass is exactly `45/524288`.

Signing makes all `L=2^20` independent 86-bit nonce draws, with replacement,
and queries the same memoized random oracle on each message/nonce pair. It
returns the first occurrence in the lowest accepted tier, or fails if none is
accepted. Repeated nonces keep their cached answers. The availability proof
handles those repetitions and gives failure at most `2^-129`, inside the
required `2^-128` limit.

The unequal alias multiplicities let the finite cut family support a spread of
class probabilities. Searching all trials for the lowest tier changes the
chosen-class distribution. This is the statistical part of the improvement:
the proof accounts for that selection rule exactly, rather than treating the
winner as an ordinary accepted sample.

## The proof mechanism

Fix the entire finite nonce table for one message. Let `A` be the fraction of
entries with no accepted tier below `j`, and `B` the fraction with no accepted
tier at most `j`. For a particular nonce in tier `j`, its probability of being
selected is

```
K_L(A,B)/N,  where N = 2^86
K_L(A,B) = sum_{t=0}^{L-1} B^t A^(L-1-t).
```

This polynomial includes equal-tier ties and duplicate draws. Its monotonicity
provides the posterior bound when a previously unexposed public coordinate is
resampled. A finite eager-table coupling carries that argument back to the
actual lazy random oracle. The rest of the oracle remains the same shared
cache, including graph queries and the signer's private nonwinning queries.
Public exposure is tracked separately from implementation-cache membership.

The final analysis divides a successful forgery into graph authentication,
replay through the public cache before signing, and a newly exposed index
input. All three charges use the same actual execution budget. Distinct public
index queries, other paid queries, and the post-sign remaining budget are
accounted for together.

For small budgets, exact stopped first and second moments control the replay
term. For large budgets, a clipped hazard process and an exponential bound
control every message row at once. Empirical good events stay inside joint
expectations; the proof does not condition the posterior argument on them.
A separate completion tower averages the conditional bad-table error after
the adversary's adaptive first stage. The small-budget branch is checked at
`(243337/245000)*κ*B`, and the large-budget branch at `0.991*κ*B`, both strictly
below `κ*B`, with `κ=2^-127`.

## What required care

An early-exit signing argument does not apply here: the all-trial signer keeps
private accepted nonwinners in the cache. Charging only implementation-cache
misses would miss later public queries to those inputs. The proof instead
retains the full private cache and charges first public exposures.

A fixed observed transcript can have an atypical completion distribution.
The small bad-table probability is proved after averaging over the actual
adaptive execution, not as a uniform pointwise promise for every transcript.
Likewise, the signing continuation budget is used only for supported outputs;
an arbitrary fixed cache need not support every syntactically possible class.

## Export and validation status

`WideHonest.admissible`, `WideWire.cost`, and `WideSecure.raw_secure` are checked
on the exact raw scheme, with only `propext`, `Classical.choice`, and `Quot.sound`.
`WideBudgetEndpoints.raw_secure_of_typed` supplies the canonical encoding
transfer for strong security, including same-message alternate signatures.
`Solution.lean` exports these exact declarations under the contract's names.

The hosted verifier accepted the complete submission as a new record on
2026-09-20: **92 compressions**, down from 100. Its durable result is
[submission 4abfb06a48549d67349e07c50b4dc5ca](https://ots.golf/submissions/4abfb06a48549d67349e07c50b4dc5ca),
checked at commit `7be6d31b9de82713e5b088f17e62e30a9198a734` in 318.7 seconds.
The original protected source tag and bot verdict retain that record.
This subsequent update changes only these notes; every Lean file and
`claim.txt` remains byte-identical to the official record source.

Further improvements should search the weighted tier schedule and the
disclosure-family geometry together, then reuse the exact first-minimum kernel
and the common-budget proof. A promising numerical schedule still needs its
finite class embedding, all-input resource bound, and actual-game security
connection checked before it can support another claim.

## Follow-up experiments: where a larger gain could come from

The next experiments below are research calculations, not additional Lean
security claims. Write `C = 2^-127 * 2^20 * M`, where M is the number of
accepted cut classes. The current construction uses C≈4.75. An exact finite
sampling argument gives a floor very close to4 for the present class-reuse
strategy. A restricted actual replay calculation supports the same floor;
it does not give a lower bound for arbitrary signature algorithms.

Changing the tree helps, but not enough by itself. Among21,209 screened
heterogeneous129-bit trees, the largest class capacity at91 compressions was
C=4.0445558341. Mixed reconstruction ranks added negligibly to that count.
It leaves little room above the class-reuse floor for the adaptive security
analysis. Uniform, mixed-arity and regular two-level families did not produce
a larger lead. These searches are bounded families, not an exhaustive search
over all trees or DAGs.

A more substantial structural change uses43 words of126bits plus an86-bit
nonce, still exactly5504bits. Four such words and an8-bit tag fit one512-bit
compression. A tree with70 chains of length14 and23 four-child branch nodes
uses1003 key-generation compressions and has raw capacity C=6.1843987025 at
verification88. Its weaker authentication has no security proof, and variable
disclosure lengths still need a canonical wire encoding.

One proposed safeguard was to retain only cuts such that moving between any
two requires at least two separately hidden chain coordinates in each
direction. Ordinary Hamming distance is insufficient: a long backward move
on one chain still needs only one hidden coordinate. The stronger directed
condition loses too many classes. Within each fixed structural frontier,
puncturing any three coordinates must be injective on such a code. Counting
the possible projections, including all allowed reconstruction ranks, gives
an upper bound C≤0.675761 across all11,420 screened126-bit trees. Requiring
three hidden coordinates and puncturing five lowers this to C≤0.068389.
These bounds require the condition across ranks as well as within a rank.

This rules out that particular global cut-code safeguard in the screened
trees. It leaves a concrete question: can an actual-game analysis safely
permit some nearby cut pairs, or can a construction obtain comparable class
capacity with stronger authentication? A raw capacity count alone cannot
answer that question. The92-compression construction remains the proved
candidate described above.

## Research after the verified 92-compression result

The original 92-compression record is the checked source at
`7be6d31b9de82713e5b088f17e62e30a9198a734`, with durable submission
[4abfb06a48549d67349e07c50b4dc5ca](https://ots.golf/submissions/4abfb06a48549d67349e07c50b4dc5ca).
The results below are subsequent mathematical experiments. They are not new
Lean security certificates or improvements to the score.

Write `L = 2^20`, `κ = 2^-127`, and normalize a class count by
`C = κ L M = M / 2^107`. The reference class-selection bound near `C = 4`
is a useful necessary gate for the existing method. A large class count is
not sufficient for security.

### A simpler reason the homogeneous 126-bit shortcut fails

The earlier raw 88-cost geometry uses 126-bit chain values. In a standard
tagged chain verifier, an exposed word with a unary successor permits an
altered signature on the same message: replace that word by a different
input with the same truncated successor. The nonce and decoded cut stay
the same. Changing the class code therefore does not fix this problem.

With a distinct tag for each step, exclude the known input and make `Q`
distinct fresh queries. Conditional on the public signature, their collision
probability is exactly `1 - (1 - 2^-126)^Q`. At `Q = 2^30`, the rational
Bonferroni lower bound, multiplied by availability, is more than `999/500`
times the protected allowance for the complete budget `Q + 2^20 + 1200`.
The reservation includes key generation, signing, recovering the index and
successor, and final verification. This argument marginalizes the private
key-generation cache; it does not condition on that whole cache.

An exact structural check of the 1,076 current-population contenders in the
11,420-tree screen found at least 72 unary reconstruction steps in every
rank-87 cut. Thus every successful signature supplies the required unary
step in those standard homogeneous constructions. The conclusion is scoped
to that reconstruction format and fresh tagged-row law, not arbitrary
schemes using some 126-bit values.

### Wider successors remove that shortcut but lose the count

A separate screen uses 126- and 129-bit values, requiring every short chain
value to have a wider immediate successor. It charges the actual child
widths and tags at every branch. With an 86-bit nonce, at most 42 disclosed
values always fit; 43 fit only when every one is 126 bits.

Across 8,067 configurations at verification cost at most 88, the largest
exact upper bound on arbitrary bit-valid mixed-rank antichains is

```
255015635831753169874095471555229 ≈ 1.5716551978730366 * 2^107.
```

The bound partitions cuts by structural frontier. Within a frontier,
ordinary chain positions form a product of finite chains. For a 43-word
frontier, alternating short positions form another product after writing
each coordinate as `s_i + 2 q_i`. A symmetric-chain decomposition bounds
each truncated product by its largest permitted rank. Summing across
frontiers ignores extra comparabilities and gives an upper bound.

Independent matching checks covered 1,440 small instances. One has width
seven although its largest cost layer has only five cuts, so replacing
antichain width by the largest layer without this argument would be wrong.
The result excludes the saved configurations, not all mixed-width DAGs,
chain-length allocations or encodings.

### Shared outputs and smaller pieces

Using both 128-bit halves of one oracle answer gives real local gains. A
shared ring has width 12 where matched separate calls have width nine.
The bounded product screen covered 139 graphs and 219,125 lift/repetition
scenarios. Its best exactly recounted family at cost 88 has
`175982422495699553309800413070113` classes, or `C ≈ 1.084575414945`.
Sharing adds only 0.0658345455% to its matched plain forest. The
disclosure-saving forks occur in expensive reconstruction tails.

A further experiment splits answers into three 65-bit pieces and accounts
for recovery of a sole unknown short input. It also rejects boundaries
constrained through just one short output: two hidden input pieces do not
by themselves provide a 130-bit check. There is a surviving local width-22
example, but the best exactly recounted split-output amplification reaches
only 0.654% of the working class-count target. The amplified split-output
counts are optimistic frontier counts, without full product antichain or
security proofs. These are bounded structural screens, with numerical
shortlisting and explicitly limited lift choices; they do not establish a general partial-word lower bound.

### Cheap proof components still need an oracle-aware relation

A Merkle transcript component with `2^18` records fits 5,248 proof bits,
786,433 signing compressions and 22 verification compressions. It still
accepts a transcript containing one false record with probability
`262143/262144`. Even 80 ideal direct record checks leave miss probability
`16379/16384`. Authenticating a transcript does not make all its entries
correct.

Baseline three-party [ZKBoo](https://eprint.iacr.org/2016/163.pdf), at its
ideal repetition error at most `2^-127`, uses 218 repetitions. Merely checking
two opened commitments per repetition requires at least 436 compressions;
one unopened 256-bit digest per repetition already takes 55,808 bits.
These are baseline-format counts, not lower bounds for every proof system.
More fundamentally, a circuit proof does not automatically implement an
opaque random-oracle gate on a private input. For example, the extended
circuit model in [EOS, Definition 3.1](https://www.usenix.org/system/files/usenixsecurity23-chiesa.pdf)
requires public inputs at random-oracle gates.

Public-key side information has a related obstacle. Conditioning a payload
on both its random root and the complete oracle table can reduce entropy,
but the verifier is not given that table. Literal fiber ranking requires
oracle work to decode. A linear root can make an omitted word recoverable
for free, but that equation alone does not bind the remaining freely
adjustable values. No low-cost decoder with the required binding resulted
from these proposals.

Likewise, hashing a short public Vandermonde syndrome of many child values
does not inherit the binding of their full concatenation. With independently
variable, verifier-consistent child payloads, the syndrome kernel permits
multiway matches among random output lists. Ordinary tuple search is free
in this model. The exact list calculations rule out the tested short-syndrome
instantiations under those assumptions; they do not rule out every nonlinear
aggregation mechanism.

### A remaining direction: weighted comparable cuts

An antichain-only decoder discards every cut derivable from another accepted
cut. An alternative is to retain comparable cuts and charge the entire
forward-compatible index mass of each returned signature.

There is a positive reference-model calculation. Take `W` mutually
incomparable two-state chains. In a chain with scaled endpoints `a <= b`,
assign class probabilities `a/(LW)` and `(b-a)/(LW)`. Their compatible masses
are `a/(LW)` and `b/(LW)`. Choose the smallest endpoint seen in `L` trials.
A rational mixture of 209 chain types gives

```
W L * mean compatible mass < 2.3,
reference failure < 2^-128.
```

The mean is unconditional, with failure contributing zero.

The reproduced upper value is about 2.29432937352; a one-state numerical
control is about 4.00766. The two-state improvement is per independent
chain. There are `2W` accepted classes, so it does not contradict the
earlier bound normalized by total class count.

The finite calculation uses the exact survival-integral formula and
`(1-S/L)^L <= exp(-S)`. An even degree-10 Taylor polynomial at `S/128`, raised
to 128, supplies rational exponential upper bounds. Atom fractions have
denominator `2^80`; endpoints have denominator `2^40`. The final comparisons
use integer arithmetic. An independent enumeration checks 48 small finite
instances, including ties and failure.

The simple embedding fails: reserving one chain coordinate for two states
and using a fixed-rank antichain in the other coordinates sacrifices too
many cuts. Even an optimistic sum for the 66-chain tree gives only
`W/2^107 ≈ 1.29543` at verification 92, below what this design needs.
A useful successor must embed comparable cuts much more densely and include
every cross-chain derivability relation. It still needs a concrete decoder,
canonical encoding, availability and an adaptive shared-oracle proof.

### Counting every comparable cut still limits the saved trees

An exact screen counted all canonical cuts through each cost cap in all
21,209 saved 129-bit trees, including comparable cuts and the root-only cut.
There were no floating-point exclusions or sampled omissions.

| Verification cap | Maximum cumulative count | Count / 2^107, approximately |
| ---: | ---: | ---: |
| 88 | 606612830856032099116847560801318 | 3.7385402099 |
| 89 | 908816182055200740272159602017498 | 5.6010121567 |
| 90 | 1355169996288672520422231030035486 | 8.3518799219 |

The same 66-chain tree uniquely maximizes all three. At cost 88, every saved
tree falls below the reference class-count gate near `4 * 2^107` even before
an antichain restriction. At costs 89 and 90, respectively 2,398 and 9,279
trees reach that raw threshold; their counts alone imply no security result.

The screen uses exact structural-mode products and cumulative coefficients
of `(1+x+...+x^L)^a`. Independent inclusion/exclusion checked 104,490
cumulative coefficients, and direct bivariate polynomial multiplication
recounted 23 trees, including the winner. This closes a combinatorial question
for the saved family, not for arbitrary trees, DAGs or oracle algorithms.

## A response-dependent checksum construction to investigate

**This section is an unproved construction direction. The submitted score
remains the officially verified 92. No 91-compression security certificate
is claimed.** Exact geometry, honest availability, and checksum algebra now
support a concrete next question; their connection to strong security is open.

The ingredient comes from response-dependent opening sequences such as
[DFORS](https://eprint.iacr.org/2020/564.pdf): use an earlier disclosed response
in the query that chooses a later opening. A literal sequence of Merkle paths
spends too many signature bits here. The proposed alternative uses a forest
cut followed by one chain opening. The forest's full nonlinear authentication
is retained.

### Concrete resource layout

Let S be a four-leaf star, and let B have children `(S, leaf, leaf, leaf)`.
The prefix root has nine B children. Each of its 63 leaf chains has length
15 and retains 126-bit values. Every prefix branch output retains 129 bits.
A separate 129-bit suffix chain has length 57. One final hash commits the
129-bit prefix root and 129-bit suffix endpoint to the 128-bit public key.
Key generation stores every chain and branch value in the secret key, so
signing later obtains disclosure values without extra reconstruction queries.

Key generation costs exactly

```
63*15 + 18 nonroot branches + 3 prefix-root compressions
      + 57 suffix steps + 1 final root = 1024.
```

Choose cuts with exactly 42 prefix disclosures, four to six of them wide
branch stops. Add one 129-bit suffix word and a 65-bit nonce. Their canonical
signature lengths are 5,498, 5,501, or 5,504 bits; the decoded class determines
the width and position of every word.

With `A(z)=1+z+...+z^15`, the independently recounted pair polynomial is

```
z^17 * (1+z+...+z^57) * (504*A^36 + 1260*A^37 + 504*A^38).
```

Here 17 charges 14 prefix branch compressions, two index queries, and the
final root. Its coefficient at 91 is
`1095633267439989883629831257669400`, about `6.75236 * 2^107` pairs.
The coefficient at 90 is about `4.49463 * 2^107`. These are counts of an
exact-cost cut family, not security conclusions.

Five-bit branch tags distinguish the 19 prefix branch nodes. An S input has
`4*126+5=509` bits; a B input has `129+3*126+5=512` bits. Both cost one
compression. The prefix root's nine wide children cost three compressions.

### A checksum small enough for the second index query

Zero-extend each short word to 129 bits, placing the three padding zeros in
the final limb `x2`, and split it into three elements of `F=GF(2^43)`.
For 42 distinct public labels `alpha_i`, define

```
J_i(x0,x1,x2) = (x0,x1,x2, alpha_i*x0 + alpha_i^2*x1 + alpha_i^3*x2),
checksum = sum_i J_i(word_i).
```

This checksum has 172 bits and costs no oracle compressions. The second
query contains a 16-bit tag, the 256-bit message, the 65-bit nonce, and this
checksum: 509 bits. A related 68-bit-nonce layout uses exactly 512 bits.
Those lengths overlap branch queries, so the stage-two tag reserves leading
five bits 31; branch tags use 0 through 18. Different tag widths alone would
not have established domain separation.

Each coordinate map is injective. Moreover, every nonzero checksum
difference belongs to at most three coordinate images: membership is a
degree-three equation in `alpha_i`. This bounds how many single-coordinate
changes can produce the same nonzero checksum difference in a fixed cut.
The field assertions have exact small-field checks; an executable field
representation uses the irreducible polynomial
`X^43+X^6+X^4+X^3+1`, checked by an exact Rabin calculation.

The checksum alone is not binding. For labels a and b, changing both words
by `(a+b,1,0)` preserves it. Also, two padded 126-bit words do not produce a
uniform 172-bit checksum: the usual padding gives binary rank 169. Neither
full checksum uniformity nor cryptographic binding may be assumed.

The distinction between unary and branch widths matters. With weak
126-bit branch outputs, two altered disclosures can meet at a single branch
hash, so two word changes need not require two separate hash equalities.
Widening every branch avoids that particular weak-branch coalescence. All
weak unary chains must stay below the branches; a weak unary node above a
branch would reintroduce the problem.

### Honest signing must pay for second-stage rejection

For a fixed total rank, each prefix cut represented in the admitted family
has exactly one permitted suffix position. At cost 91 its prefix reconstruction
cost is `31 <= r <= 88`, with suffix position `88-r`. Decoding the second
answer only among permitted completions would
make that answer irrelevant. Instead use a fixed 58-position suffix alphabet,
with `floor(2^256/58)` aliases per position. Reject both unassigned oracle
outputs and positions incompatible with the selected prefix.

There is an exact honest-availability calculation for this structure. Put
`L=2^20`, `T=L-8192=1040384`, and sample T distinct nonces uniformly without
replacement. A first challenge passes a cheap filter with probability
`5221/L`; on a pass it also selects a canonical admitted prefix. Make at most
8,192 second queries, keeping completed paths and returning one by a fixed
rule. The signing cost is pathwise at most `T+8192=L`.

Every permitted suffix has probability
`a=floor(2^256/58)/2^256`, with `5221*a>90` and `a>1/59`.
Exact rational block bounds put failure below

```
(4/5)*2^-128 + 2^-138 < 2^-128.
```

The first term bounds no completed path over all T trials; the second covers
stopping at the continuation cap before any success. Distinct nonces and
separated query domains make the honest queries fresh conditional on the
key and any public-key-dependent message. This is a different sampler from
the verified construction's sampling with replacement. Its security proof
does not transfer automatically. With `kappa=2^-127`, the effective-trial
normalization is `kappa*T*M ≈ 6.69961` at cost 91. The raw pair count remains
`M ≈ 6.75236 * 2^107`.

### The open problem

Can response-dependent checksum selection turn this resource-valid family
into a strongly secure scheme in the actual shared-oracle game? The missing
proof must handle different decoded cuts, prior index queries, hidden chain
preimages, checksum coincidences, suffix derivations, and adaptive message
selection under one charged budget. A marginal probability bound for one
event is insufficient after conditioning on a selected signature.

One useful abstract lemma is exact: if each next counted mark has conditional
probability at most `2*kappa`, at most one mark occurs per trial, and there
are at most B trials, the probability of two marks is at most `kappa*B`.
Stop the counter at its second mark and take expectations. Applying that
lemma requires a valid event definition and conditional bound in the actual
game; two changed words alone do not establish either hypothesis.

The concrete contribution here is a compact challenge input while retaining
the complete nonlinear reconstruction, together with exact resource and
honest-signing calculations. Establishing the missing game connection, or
finding a failure of it, is the next useful step. The 92-compression proof
files and claim remain unchanged.

## Further checkpoint: executable references and a pre-sign replay obstruction

The submitted proof and claim remain **92**. The resource-correct
89-compression prototype described below is **rejected by an exact pre-sign
replay counterexample**. Its honest-signing calculation and the independent
probability lemmas remain useful, but they do not establish security.
The larger-checksum idea alone cannot fix unchanged-payload replay.

### The 91-compression reference is executable

The nonce-65 construction now has a canonical rank/unrank decoder, full key
generation, mixed-width wire codec, capped signer and verifier.
The executable signer uses a fixed nonce order, whose security limitation is
explained in the replay section below. The uniform-distinct sampler remains
a separate, unproved reference. Structural
patterns use multinomial ranking; bounded-composition counts unrank the
chain costs and paired suffix. All 2,268 structural patterns, 537 boundary
and random geometry ranks, and 2,925 independently recounted coefficients
passed. Guided correctness fixtures cover both rejection paths and all
canonical lengths; malformed wires are rejected.

One complete sampled signing execution, without forced oracle answers,
used 1,040,384 first queries and 5,133 second queries, found 93 completed
candidates, and returned a 5,501-bit signature that verified in exactly 91
compressions. Key generation used exactly 1,024 compressions. This is an
executable consistency/resource check using a reproducible simulated oracle,
not an availability estimate, production cryptography or a security proof.

### A combined probability lemma

Consider mutually independent groups, each with one Bernoulli(a) gate and
at most d Bernoulli(p) candidate bits. Queries reveal one bit at a cost of
one; arbitrary adaptive interleaving and cached repeats are allowed. Success
requires either two distinct observed positive candidates anywhere or an
observed positive gate and positive candidate in the same group.

If a<=1/2 and a*d<=1, then for every p and integer budget B,

```
Pr[success] <= min(1,p*B/2).
```

Before any positive candidate, let t count unread candidates whose gates are
already known positive. The potential p*(b+t)/2 covers b remaining queries.
A gate query creates at most d tickets with probability a, which its budget
decrement pays for when ad<=1. A ticket query either wins or consumes its
ticket. An unticketed positive enters a one-positive state; granting its
gate query for free bounds that state's success by (1+pb)/2. These three
transitions prove the result by finite induction. This bounds the combined
event directly. The conditions are also necessary for uniform validity
over all p and B; simple small-p policies violate it when either fails.

The exact dynamic program checked 1,375 in-regime budget cases and an
independent labeled-history solver agreed on 27 small cases. For a=1/58,
d=45 or 48, and p=2*kappa, the theorem gives kappa*B. It remains an abstract
independent-bit theorem: identifying those groups with shared-oracle
observations is a separate obligation. Standalone Lean files already check
the weaker grouped-gate moment algebra and its sharper query-cost
optimization; the full combined-policy induction is not yet formalized.

### Suffix forest capacity screen

Replacing the single suffix chain with two through seven wide chains lost
capacity in a screen of 151 prefix trees and 28,690 resource layouts. At
score 91, the best normalized pair counts were 6.75236 for one suffix word,
5.52601 for two, and 4.99074 for three; the corresponding suffix alphabets
grew from 58 to 729 and 4096. Every tested capacity/alphabet Pareto point at
scores 86, 88, 90 and 91 used one suffix chain. This rejects the tested family,
not all possible response-dependent suffix constructions.

### More checksum constraints without paying for another query

A 215-bit checksum over GF(2^43) maps each 129-bit word x=(x0, x1, x2) at a
nonzero label a to

```
q = x0+a*x1+a^2*x2
J_a(x) = (x0,x1,x2,a*q,a^2*q).
```

Every nonzero difference belongs to at most two coordinate images: either
its last two components determine a, or its first three define a nonzero
quadratic with at most two roots. Injectivity and this generic-field
statement pass strict Lean 4.33.1 with allowed axioms only. The checksum
still has explicit two-coordinate kernels; fewer explanations of a nonzero
difference does not imply stronger binding at difference zero.

A separate Vandermonde checksum uses moments 0..r-1 over a larger field.
Every r distinct columns are independent, so equal checksums require at least
r+1 changed coordinates. Four 129-bit symbols cost 516 bits; five cost 645 bits,
and both fit a two-compression second query at the tested nonce widths.
The latter is therefore a stronger algebraic choice at the same query cost.
Exact Rabin checks certify the executable field polynomial X^129+X^5+1.
These bit-field calculations are not yet linked to Lean.

For 124-bit short chain words, six GF(2^124) symbols take 744 bits. Assign zero
checksum contribution to the 129-bit branch disclosures and label short
values by their fixed DFS positions. Under the fixed-cut structural lemma,
a changed wide disclosure already entails the separate wide-coincidence
alternative. Otherwise equal checksums and changed prefix data require at
least seven distinct weak unary coincidences. The exact field polynomial
X^124+X^19+1 passes a Rabin irreducibility certificate; 2,509 complete
small-field minors and 48 large-field minors also pass. A seven-coordinate
kernel witness confirms that the map is still not binding by itself.

### Concrete 89-compression resource and honest-signing reference

Let S be a four-chain star and B=(S,leaf,leaf,leaf). Use a prefix root with
twelve S children and one B child: 55 chains of length 17, retaining 124 bits;
every branch retains 129 bits. Add a 129-bit suffix chain of length 70 and
a final root committing both roots. Key generation costs

```
55*17 +18 prefix branch compressions +70 suffix steps +1 final root =1024.
```

Choose 43-word prefix cuts with at most four wide stops. Their fixed-cost
polynomial, including the suffix, is

```
z^18 * (1+z+...+z^70) * (66*A(z)^40 +715*A(z)^39),
A(z)=1+z+...+z^17.
```

The score 89 coefficient is 817424621335596697141127222311949. Every prefix
has a unique suffix partner at this total cost. A 20-bit nonce yields
canonical lengths 5,496 or 5,501 bits. The second query has exactly
256+20+744+4=1024 bits and costs two compressions. All other query lengths
are distinct from 1024. Thus the resource accounting is concrete, but the
20-bit nonce is ruled out by the pre-sign/cross-message calculation below.

The existing 72-tier reference fits this capacity after increasing only the
last population from 91*2^33 to 107*2^33. Individual rates stay 2^(j-128);
total complete-trial reference mass is 91/2^20. Give each tier-j class
71*(2^128+1)*2^j first-index aliases. The second decoder divides its answer
space equally among 71 fixed suffix positions, rejecting 60 leftover answers
and all positions except the class's paired suffix.

Scan T=2^20-16384 distinct nonces, permit 8,192 second queries at two
compressions each, and abort/discard candidates on prefix overflow.
Exact integer and directed-interval calculations give

```
total signing cost <=2^20
prefix overflow probability <2^-315
total signing failure <0.424 *2^-128
uncapped mean selected individual-class rate <0.911 *kappa.
```

The last quantity is not a compatible-class or full-security bound.

The 89-compression candidate now also has an executable canonical decoder,
codec, key generator and verifier. Its full sampled signing run used
1,032,192 first queries and 6,266 second queries (costing two compressions
apiece): 1,044,724 signing compressions total. It found 97 completed
candidates and returned a 5,501-bit signature that verified in exactly 89
compressions. No oracle answers were forced in this run. The message was
chosen as the public key concatenated with itself. Independent checks cover
2,952 composition coefficients, all 781 structural patterns, 523 ranks,
64 guided signatures, 512 malformed wires and the continuation overflow.
This is executable consistency evidence, separate from security.

### An exact seven-mark ticket potential

The numerical experiments led to an all-budget theorem for an auxiliary
independent model. Its state has fewer than seven positive marks and t
unread candidates behind positive gates. Ticket candidates cost one and
win with probability p. Unticketed positives receive a free gate chance
1/71, then add a mark if that chance fails. A gate costs two and supplies
17 tickets with probability 1/71. Seven marks also win. Additionally allow
one-cost direct winning queries with conditional probability at most 3p/25.
For every adaptive policy, integer budget B, and 0 <= p <= 2^-20,

```
Pr[win] <= min(1,p*B/8).
```

The proof uses a multiplicative survival potential:

```
q=1-142p/159, u=1-3p/25, z=p*(70/71)/(1-p/71)
V_b(j,t)=1-q^t*u^b*Pr[Binomial(b,z)<=6-j].
```

The binomial recurrence and three scalar inequalities pay for each action
against the same budget. For the initial state, small pB follows from a
seventh factorial moment, pB >= 8 is automatic, and 1 <= pB <= 8 is covered
by 1,792 exact rational intervals with a strictly positive margin. The
script checks 23,275 additional exact transitions. Thus this is a finite,
all-budget mathematical certificate, not a Poisson extrapolation or a
floating-point observation. At p=2^-124=8*kappa it yields kappa*B.

The adaptive-policy theorem is not yet formalized in Lean. Its independent
coins and permitted direct conditional rates have not been established for
the shared-oracle construction. In particular an unconditional mean class
rate cannot replace a conditional-rate premise, and gates on several
changed coordinates remain outside this auxiliary model.

### Exact rejection of the 20-bit nonce design

Query the first index on q=2^72 distinct messages at nonce zero. Tier zero
has n=19*2^104 classes with individual first-answer probability
r=71*(2^128+1)/2^256. If X counts unordered message pairs decoding to the
same tier-zero class, then

```
E[X]   = choose(q,2)*n*r^2
E[X^2] = E[X]+6*choose(q,3)*n*r^3+6*choose(q,4)*(n*r^2)^2.
```

The exact second-moment bound gives Pr[X>0] > 0.994682784476. Select one
message from such a pair for signing and retain the other. The two classes
have identical correct disclosures, suffix positions and checksums. If the
signer returns its nonce-zero candidate, the same signature verifies on the
other message whenever that message's fresh second gate succeeds, with
probability approximately 1/71. A stronger checksum does not prevent reuse
of unchanged values.

For the prototype's fixed scan beginning at zero, the planted tier-zero
candidate is always selected when its second gate succeeds, unless the
prefix cap overflows. Its conditional overflow probability is below 2^-315.
This gives forgery probability above 0.000197318544827.

Uniformly sampling ordered distinct nonces from the 20-bit space does not
rescue the construction. Nonce zero is included with probability 63/64.
Requiring no other completed tier-zero candidate gives probability greater
than 0.310694600286 for the remaining trials. The resulting forgery lower
bound is above 0.000060347903189. Conservatively charging q first queries,
all 1,024 key-generation compressions, the entire 2^20 signing budget and
89 verification compressions gives an allowed probability below 2.776e-17.
The lower bound exceeds it by more than **2.17 trillion times**.

This is an exact rational certificate for the stated two-stage construction,
not a universal nonce lower bound. The fixed-scan 91 prototype has the same
policy problem despite its wider nominal nonce field. The separately
proposed uniform-distinct 65-bit reference is not rejected by this specific
calculation and still needs its own full pre-sign argument.

### A separate hidden-root index direction

To remove the public first-index input used above, one option is to serialize
a 110-bit class index, reconstruct the 129-bit prefix root first, and check
H(message,nonce,prefixRoot) against the serialized class. The signer already
knows that root; the first input remains one compression at 405 bits. The
signature metadata allows the verifier to reconstruct before checking the
index. Secrecy of the root and all security consequences remain unproved.

Charging the complete metadata, an exact screen of 1,139 trees and 2,914
length allocations finds normalized capacity 4.50076 at score 91 for a fixed
word count, or 4.67015 with canonical variable counts. Both are below the
current schedule's approximately 4.75 requirement. This did not yet produce
a replacement improvement; it identifies a concrete cost of hiding the
first-index input.

### Open questions for a replacement construction

1. Find a mechanism that controls pre-sign class-pair replay while retaining
   enough cut capacity. The rejected short-nonce construction cannot be
   repaired by completing its old proof outline.
2. Give a shared-oracle coupling that controls the combined weak, wide,
   index and replay events against one actual query budget. Independent
   bit-group probabilities cannot simply be multiplied into this game.
3. Handle changed checksums with two through six changed coordinates.
   A model containing only one gated candidate and seven ordinary marks
   does not cover every such event; the Vandermonde support structure
   supplies extra constraints that still need to be used.
4. Extend the fixed-cut argument to different decoded cuts and prove the
   pre-sign/cross-message statements with the much smaller nonce space.
5. Formalize the constructive decoder, canonical wire and full resource,
   correctness, availability and strong-security exports for any replacement.

The community's [RISC-V PR #9](https://github.com/leanEthereum/ots.golf-submissions/pull/9#issuecomment-5748293743)
reached a durable 693-cycle result, with its
underlying compression scheme unchanged. Repository Discussions were still
disabled on the latest capability check; these explicit questions remain
in the submission notes for others to examine. The verified compression
claim in this PR remains 92.

## Next checkpoint: a hidden suffix endpoint and a suffix-free alternative

The submitted proof and claim remain **92**. Two different mechanisms now pass
exact resource screens below 92. The first also has a full executable signer and
verifier. Neither has a security certificate; the public-index 89 prototype
rejected above remains rejected.

### Recover the index salt before decoding, using three metadata bits

The first mechanism keeps the prefix tree with twelve four-chain stars S and
one B=(S,leaf,leaf,leaf), but uses 55 length 18 short chains and a seven-step wide
suffix chain. Write E for the 129-bit suffix endpoint. The 128-bit public key is
H(finalTag,prefixRoot,E). The signer knows E and makes first queries
H(message256,nonce20,E129), of 405 bits. A complete decoded class specifies both
the prefix cut and its paired suffix distance q in 0..7.

Serialize nonce20, q3, the 43 canonical mixed-width prefix words, and the 129-bit
suffix disclosure last. The verifier can read q and the last word before it
knows the prefix layout. It performs the q already-budgeted suffix hashes,
recovers a proposed E, checks the first index, and requires the decoded q to
equal the serialized q. It then parses the prefix normally. This resolves the
layout/salt dependency with three explicit bits rather than a 110-bit class
header; it adds no oracle call and no honest consistency rejection.

Keep 71 bins in the second decoder even though only eight physical suffix
positions occur. The checksum query has message256+nonce20+checksum744+tag4
=1024 bits and costs two compressions. Bins 8..70 simply reject. Each actual
position therefore retains probability floor(2^256/71)/2^256, and the same
first-stage aliases preserve the existing 72-tier reference without adjusting
its weights.

With A(z)=1+...+z^18, the exact total-cost polynomial is

```
z^18 (1+...+z^7) (66 A(z)^40 +715 A(z)^39).
```

Its cost 89 coefficient is 798472090123800819672469325035850, larger than the
required 770731564938763476110588254355456. Key generation costs
55*18+18+7+1=1016. The two canonical wire lengths are 5499 and 5504 bits.
All query domains are separated by their input lengths. Early rejection costs
at most 10 compressions; every admitted final-root path costs exactly 89.
An independent reviewer checked 3,672 mode, position, domain and rejection cases.

The executable full signing run used 1,032,192 first queries and 6,266 second
queries, for 1,044,724 signing compressions. It found 97 completed candidates and
returned a 5499-bit signature verified in 89 compressions. This used a seeded
simulated oracle without forced answers; it is a consistency/resource example,
not an empirical security or availability theorem. The honest fresh-index
reference keeps the earlier exact failure bound below 0.424*2^-128 because the
accepted class probabilities and continuation cap are unchanged.

The known public-index replay calculation no longer has a publicly available
first input before signing. That observation does not establish hiding: E is
related to the public key and key-generation oracle, so a stopped-exposure
argument is required. E becomes recoverable after a signature in at most seven
suffix queries. Any accepted reconstruction using a different pair of roots
also creates a final-root coincidence, which must be charged in the same
security budget. None of these probability obligations is discharged by the
resource calculation.

### Remove the suffix and keep a 128-bit nonce

A separate mechanism makes the second query a fixed acceptance predicate of
probability floor(2^256/71)/2^256. It removes the suffix disclosure, suffix
chain and final two-root commitment entirely. The prefix root is the 128-bit
public key. Both index queries retain the full 256-bit message; the second
uses a 620-bit, five-moment checksum and 128-bit nonce, so its input is 1020 bits.

Let S be a four-chain star and T=(S,S,leaf,leaf); the root has seven T children.
There are 70 chains of length 14,14 S nodes, seven T nodes and the root. Nonroot
branches retain 129 bits and chains 124 bits. Key generation costs
70*14+14+7+2=1003. Admitted 43-word cuts have 36, 38 or 40 short disclosures and
seven, five or three wide disclosures. Their signatures occupy 5495, 5485 or 5475
bits including the nonce.

For A(z)=1+...+z^14, independent multinomial and coefficient calculations give

```
z^17 (6468 A(z)^36 +2520 A(z)^38 +35 A(z)^40).
```

The cost 90 coefficient is 867566206394604337533155603395168, exceeding the same
unchanged population. Every admitted prefix reconstructs with 87 compressions;
one first-index and two second-index compressions give 90. The new root and
index lengths are disjoint. This is a resource/algebra/reference calculation;
an executable full wire adapter and all protected Lean exports remain to be
built.

Five GF(2^124) Vandermonde moments occupy 620 bits. Restricted to the short
coordinates of one fixed cut, this map has minimum nonzero kernel support six.
Wide disclosures contribute zero and require a separate wide-coincidence
argument. The exact field audit checks
X^124+X^19+1, 1,585 small-field column subsets, 48 full-size minors and an explicit
six-coordinate kernel. The checksum is not binding by itself. The same honest
reference calculation passes with a uniform ordered sample of distinct 128-bit
nonces; pre-sign security still needs its own argument.

### A stronger abstract probability theorem, with a checked induction

A new finite opportunity potential handles six marks, gates for every subset
of previously found coordinate changes, prepaid gate tickets, and direct wins
in a single budget. Set a=1/71,c=3/25,0<=p<=2^-20. A paid candidate is positive
with probability p; its jth positive grants 2^(j-1) fresh gates for free, and
six positives win automatically. A paid direct query may win with conditional
probability at most cp. A gate costs two and, with probability a, adds 18 ticket
candidates; each ticket costs one and wins with probability p. All these are
explicit independent-model premises.

For arbitrary adaptive interleaving and integer budget B,

```
Pr[win] <= min(1,pB/8),
```

with strict Pr[win]<pB/8 when p>0 and B>0. At p=2^-124 this is kappa*B.
The proof uses a finite survival Bellman table,

```
S_0(j)=1 (j<6), S_n(6)=0,
S_(n+1)(j)=min((1-c)S_n(j),(1-g_j)S_n(j+1)),
g_j=1-(1-a)^(2^j).
```

Put H_b(j)=E[S_N(j)] for N~Binomial(b,p), q=1-142p/159, and
V_b(j,t)=1-q^t H_b(j). The binomial recurrence supplies the direct and marked
transitions; (1-cp)q<=1-p and (1-cp)^2<=1-a+a*q^18 pay for tickets and gates.
The initial finite table has S_n(0)=(1-c)^n for n<6 and zero thereafter. Its
truncated binomial survival bound passes 3,584 exact rational intervals,
with minimum certified margin above 0.0099. Small and large scaled budgets
are handled analytically, including strictness at pB=8.

Independent checks cover 889 action strings, all 3,584 intervals and 8,880
transition instances. A standalone strict Lean 4.33.1 file proves the generic
induction from local potential inequalities to the recursive Bellman-value
bound for every budget and state, with allowed axioms only. Stochastic policy semantics are not separately
formalized in that file. The concrete
binomial inequalities and rational interval certificate have not yet been
formalized in Lean, and the actual shared-oracle construction has not been
identified with this model.

### The query-graph gap and the next decisive questions

The 744-bit, six-moment checksum of the 89 candidate has a useful property
for short-coordinate differences in one fixed cut, assuming no wide change:
with at most four already available coordinate changes, one gate checksum
has at most one completion using those changes plus a single new coordinate
value. For the 620-bit, five-moment checksum of the 90 candidate, the analogous
guarantee reaches only three earlier changed coordinates. Two such
completions would differ on at most six coordinates, contradicting the
Vandermonde kernel threshold. This helps control a gate queried before its
needed coordinate is found.

However, one target-relative hash coincidence need not expose just one new
disclosure. Two alternative starting values can already have merged at an
intermediate node; one later coincidence can then make both starts usable,
with different checksum gates. This deterministic witness invalidates the
simplest one-value-per-mark mapping. It is a proof gap, not a forgery exceeding
the protected target. Query graphs with merging, changes between cuts, and
the signer's private cache remain essential parts of the security problem.

The public journal also contains Holindauer's new verified Generality 3 lower
bound of 2, with a cache-product martingale that compares computations directly
from the same starting cache. Its [notes and checked source](https://ots.golf/submissions/5e5652431676c59f6f6effeaef428d57)
provide a relevant proof pattern for deferred exposure. No theorem from that
separate root is imported into this submission.

Concrete questions for the next solver:

1. Can a potential charge merging preimage paths and prepaid checksum gates
   together, so one target hit may reveal several old starts without assuming
   independent candidate groups?
2. Can the hidden endpoint be exposed only after signing while bounding every
   pre-sign way to learn it, including key-generation cache intersections?
3. Can the fixed-cut checksum argument extend to different canonical cuts and
   the selected class's actual conditional distribution, within one budget?
4. Can the concrete binomial transform, interval certificate and oracle-game
   reduction be brought into Lean with the generic induction already checked?

Both repositories still have Discussions disabled. These questions are posted
here in the authorized submission notes. The verified score remains 92.
