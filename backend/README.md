# MobyAds Backend Contract (M2-M3) — Single Source of Truth

Per PDF §2, §8, §12, §16, §21, §29: **Flutter = UI, Backend = Authority**.

Currency: `INR` default (existing app/admin). `currency` column stays configurable
so `GBP` from PDF can be enabled per market via `app_config`.

## Tables

See `schema.sql` for Postgres DDL with idempotency unique constraints.

- `users` — server-side id, `account_status NORMAL|REVIEW|BLOCKED`,
  `verification_status VERIFIED|UNVERIFIED`
- `questions` — `correct_option_index` NEVER sent to client.
  Status unified: `PENDING_REVIEW|ACTIVE|REJECTED|EXPIRED|RETIRED`
  (`ACTIVE` == old Flutter `published`)
- `task_attempts` — `idempotency_key UNIQUE`, prevents double reward on retry
- `reward_transactions` — auditable ledger.
  Status: `PENDING|AVAILABLE|WITHDRAWN|REVERSED|FAILED`.
  `UNIQUE(source_type, source_id)` — duplicate SSV callbacks cannot pay twice
- `reward_sessions` — opaque id for AdMob custom-data, `provider_transaction_id UNIQUE`
- `coupons`, `user_coupons` — M5 ready, unused by M2-M3 flows
- `withdrawals` — `PENDING|APPROVED|PROCESSING|PAID|FAILED|REJECTED`,
  `idempotency_key UNIQUE`, reserve logic in backend (not client)
- `app_config` — `min_withdrawal, daily_limit, task_cooldown_minutes,
  reward_mcq, reward_ad, mcq_count` — server-configured, no hardcode

## API

See `openapi.yaml`. Base: `{BASE_URL}/api/v1`.

Client (Flutter) uses `/auth, /quizzes, /reward-sessions, /wallet,
/coupons/me, /payout-methods, /withdrawals, /config/public`.
Admin (Next.js) uses `/admin/*` with `ADMIN_JWT` (separate secret from user JWT).

## Client mirrors

- Flutter: `lib/core/network/api_endpoints.dart` (paths) +
  `lib/models/server_contract.dart` (DTOs, snake_case wire format)
- Admin: `lib/types/api-contract.ts` (same shapes, camelCase after transform) +
  `lib/api-client.ts` (typed fetch, `NEXT_PUBLIC_API_BASE_URL`)
