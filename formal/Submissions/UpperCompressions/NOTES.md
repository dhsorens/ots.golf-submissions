# Candidate 92: weighted minimum selection over disclosure cuts

This construction has a Lean-checked verifier bound of 92 hash compressions on
every raw input and every oracle-answer path, together with the exact contract's
raw-signature admissibility and strong-security theorems. The existing record
is 100; official verification and publication of 92 are pending. An isolated
mathematical check does not replace the hosted verdict or establish a new record.

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
