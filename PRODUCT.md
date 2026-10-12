# MobyAds App — PRODUCT.md

Platform: `adaptive` (Flutter, iOS + Android). Impeccable native support is alpha: use it for direction, briefs, critique, distill, copy, audits; visual iteration via 390px web prototype or pasted Flutter screenshots.

## Audience

Everyday users (students, part-time earners) on phones, quick 1–5 minute sessions, often one-handed, often mid-range Android.

## Job

Complete small tasks (MCQs, rewarded ads), see exactly what was earned, trust the money is real, withdraw to a bank account.

## Constraints

- Backend is the authority for rewards/balances; UI must never imply a balance is final before server confirms. Use Pending / Reward processing states (slices 1–4: `server_config`, `quiz/submit`, wallet ledger read, reward-session + SSV).
- Money shown as currency + amount; Available / Pending / Withdrawn / Reversed clearly separated (spec §14). Status labels/colors/icons match root DESIGN.md exactly.
- Reward values, limits, ad availability are server-configured (`GET /config/public`), never hard-coded in copy. Sample figures in designs are illustrative until rules freeze.
- Regulated context (ads + rewards + bank withdrawals): disclosures and terms visible (spec §26).
- Touch targets ≥ platform minimums; dark mode + dynamic text size supported.

## Pending business rules

Undecided (affect design incl. number formatting): reward per MCQ/ad, daily task/ad limits, minimum withdrawal, fees, processing time, launch currency (spec examples GBP vs current INR config). Current code defaults (INR): min 50, daily 1000, cooldown 60m, 10Q, ₹1.50/Q, ₹2.00/ad — treat as placeholders.
