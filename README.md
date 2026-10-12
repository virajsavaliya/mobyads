# MobyAds — Earn with Quiz (Flutter App + Admin Panel + Backend Contract)

MobyAds is a reward-earning platform: users answer daily MCQ quizzes and watch
rewarded ads, earnings land in a wallet ledger, and eligible users withdraw to
bank / Paytm payout methods. An internal Next.js admin panel manages users,
questions, withdrawals, coupons, fraud review, and platform configuration.

> **Core rule (applies to all design and code):** the Flutter app is the UI;
> the backend is the authority for rewards, balances, and withdrawals. The UI
> must never imply a balance is final before the server confirms — use
> `Pending` / `Reward processing` states. Fresh accounts start at **₹0.00**;
> money appears only after real quiz/ad completions.

## Repository layout

```
mobyads/
├── lib/                        # Flutter app (Riverpod + GoRouter + google_mobile_ads)
│   ├── core/                   # config, network (Dio ApiClient), storage, theme, router
│   ├── features/               # auth, home, tasks, mcq, ads, wallet, coupons,
│   │                           # withdrawals, profile, notifications
│   ├── models/                 # UserModel + server_contract.dart (backend DTOs)
│   ├── services/               # auth_service, ad_service
│   └── widgets/                # shared UI (incl. legal_doc_screen.dart)
├── mobyads-admin/              # Next.js 16 admin panel (App Router, Tailwind, shadcn)
│   ├── app/(dashboard)/        # dashboard, users, mcq, ads, withdrawals,
│   │                           # coupons, fraud, audit, settings
│   ├── components/             # layout (Sidebar, TopBar) + shared + ui
│   └── lib/                    # types, api-client, api-contract, fraud helpers
├── backend/                    # Single source of truth for the API
│   ├── schema.sql              # Postgres: users, questions, task_attempts,
│   │                           # reward_transactions (ledger), reward_sessions,
│   │                           # coupons, withdrawals, app_config
│   └── openapi.yaml            # REST contract (v1)
├── test/                       # 73 Flutter tests (flutter test → all pass)
├── PRODUCT.md                  # Audience, job, constraints, pending business rules
├── DESIGN.md                   # Canonical brand, status vocabulary, type/spacing
└── README.md
```

## Mobile app — screens & flows

| Area | Route | Behavior |
|---|---|---|
| Splash | `/splash` | Logo + loader, session check → `/home` or `/login` |
| Login / Register | `/login`, `/register` | Email + Google (mock); Terms/Privacy consent on login |
| Home | `/home` | Balance hero (Available, tabular figures + Pending + Withdraw CTA), one next-task card, stats, ad carousel |
| Quiz | `/quiz` | 10 MCQs, rewarded-ad gates on Q5/Q10 with AdMob SSV session (`customData`), server-validated submit with idempotency keys, offline fallback |
| Wallet | `/wallet` | Ledger-derived buckets (Available/Pending/Total/Withdrawn), date-grouped history, server-driven minimum in info dialog |
| Coupons | `/coupons` | Available/Used/Expired tabs; code hidden until revealed; copy + redeem; terms collapsed |
| Withdraw | `/withdraw` | Server-driven minimum, payout methods (bank/Paytm), fee/ETA expander, double-submit guard, lifecycle stepper (Requested → Approved → Processing → Paid; failure shows reason + funds-returned) |
| Profile | `/profile/*` | Edit profile, payout methods, notifications, My Coupons, Privacy/Terms (Read-mode docs with table of contents), Help, About |
| Tasks | `/tasks` | Featured task card + check-in/video/referral actions |

## Admin panel — pages

Dashboard (4 KPIs + needs-attention strip) · Users (6-column table, tabbed detail drawer, block/verify actions) · MCQ bank (list + edit drawer, typed bulk JSON import with validation) · Ads & SSV logs · Withdrawals (approve/reject with **required reason**, risk badges) · Coupons (create/enable/disable) · Fraud & Risk (review/blocked/unverified-balance/duplicate-destination alerts) · Audit log · Settings (env badge, server/local source indicator, TEST AdMob group).

Demo login: `admin@mobyads.internal` / `admin12345`. Until the backend is built,
both clients run on local mocks behind the contract interfaces — admin edits do
not reach the app yet.

## Design system (for design contributors)

- Start with `PRODUCT.md` (per surface) and `DESIGN.md` (canonical).
- Fixed status vocabulary everywhere — ledger: `PENDING, AVAILABLE, WITHDRAWN,
  REVERSED, FAILED`; withdrawals: `PENDING, APPROVED, PROCESSING, PAID,
  REJECTED`. Same label, color, and icon in app and admin.
- Brand: ocean teal `#0E7490`, money green `#10B981`, coin gold `#F59E0B`;
  headings Poppins, body Inter; money figures largest with tabular numerals;
  one primary action per screen; 48px minimum touch targets.
- Surface briefs live in `.impeccable/surfaces/`; page modes: Operate (tasks),
  Persuade (splash/onboarding), Read (legal docs — never distill away content).

## Run it

**App (iOS/Android):** `flutter pub get && flutter run` (iOS floor 15.0,
see `ios/Podfile`). Uses Google test ad units — swap to production IDs at
release. **Admin:** `cd mobyads-admin && npm install && npm run dev` →
`http://localhost:3000`. Checks: `flutter analyze && flutter test` ·
`npm run lint && npx tsc --noEmit && npm run build`.

## Status & roadmap

Done: contract, server-driven config, quiz submit, wallet ledger, ad sessions,
coupons, stepper, full design pass (73 tests green, admin lint clean). Next:
real backend implementation, payout provider integration, TestFlight/Play
testing, legal sign-off, production AdMob IDs. Undecided rules (rewards,
limits, fees, launch currency) are tracked as pending in `PRODUCT.md`.
