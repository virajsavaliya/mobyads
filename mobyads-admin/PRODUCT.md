# MobyAds Admin — PRODUCT.md

Platform: `web` (desktop-first). Full Impeccable workflow applies: Live Mode, detector, `extract`/`generate`/`live`.

## Audience

Internal operators reviewing users, MCQs, ledger, withdrawals, fraud.

## Job

Decide fast and audit everything: 4–6 KPIs + needs-attention list, approve/reject withdrawals with required reason, block/unblock with audit trail.

## Constraints

- All pages Operate mode. Shared table/filter/drawer pattern (`components/shared/`).
- Environment badge (dev/staging/prod) persistent. Destructive actions (block, reverse, reject) need confirm + reason.
- Status labels/colors match root DESIGN.md exactly; this file overrides layout + density only.
- Reads same backend contract (`lib/types/api-contract.ts`, `lib/api-client.ts` via `NEXT_PUBLIC_API_BASE_URL`).

## Pending business rules

Same as app PRODUCT.md: rewards, limits, min withdrawal, fees, currency pending. Admin edits these values once backend lands; until then settings page shows Local fallback badge.
