-- MobyAds M2-M3 Postgres schema (PDF §5,7,8,12,13,16)
-- Currency configurable; default INR (app currently ships INR).

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users: backend owns accountStatus + verificationStatus (PDF §5)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email CITEXT UNIQUE NOT NULL,
  phone TEXT,
  date_of_birth DATE,
  country TEXT,
  account_status TEXT NOT NULL DEFAULT 'NORMAL'
    CHECK (account_status IN ('NORMAL','REVIEW','BLOCKED')),
  verification_status TEXT NOT NULL DEFAULT 'UNVERIFIED'
    CHECK (verification_status IN ('VERIFIED','UNVERIFIED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_active_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Questions: correct_option_index server-only, never to client (PDF §7)
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  options JSONB NOT NULL, -- exactly 4 strings
  correct_option_index INT NOT NULL CHECK (correct_option_index BETWEEN 0 AND 3),
  explanation TEXT,
  category TEXT NOT NULL DEFAULT 'GENERAL',
  source_name TEXT,
  source_url TEXT,
  source_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status TEXT NOT NULL DEFAULT 'PENDING_REVIEW'
    CHECK (status IN ('PENDING_REVIEW','ACTIVE','REJECTED','EXPIRED','RETIRED')),
  reward_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  reward_currency CHAR(3) NOT NULL DEFAULT 'INR',
  active_from TIMESTAMPTZ,
  active_to TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_questions_status ON questions(status);

-- Attempts: retry-safe via idempotency_key (PDF §7: unique task-attempt ID)
CREATE TABLE task_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  idempotency_key TEXT UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  selected_index INT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  reward_txn_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ledger: NEVER update balance directly; derive from here (PDF §8, §21)
CREATE TABLE reward_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  source_type TEXT NOT NULL
    CHECK (source_type IN ('MCQ','AD_REWARD','DAILY','REFERRAL','WITHDRAWAL','COUPON')),
  source_id TEXT NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  status TEXT NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','AVAILABLE','WITHDRAWN','REVERSED','FAILED')),
  available_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (source_type, source_id)
);
CREATE INDEX idx_ledger_user_status ON reward_transactions(user_id, status);

-- Reward sessions for AdMob SSV custom-data (PDF §11-12, opaque id)
CREATE TABLE reward_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  task_type TEXT NOT NULL CHECK (task_type IN ('MCQ','REWARDED_AD')),
  status TEXT NOT NULL DEFAULT 'CREATED'
    CHECK (status IN ('CREATED','COMPLETED','FAILED')),
  provider_transaction_id TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

-- Coupons (M5 ready, PDF §13)
CREATE TABLE coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  value NUMERIC(10,2) NOT NULL,
  type TEXT NOT NULL DEFAULT 'CASHBACK',
  expiry_date DATE,
  status TEXT NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('ACTIVE','DISABLED','EXPIRED'))
);
CREATE TABLE user_coupons (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  redeemed_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'ISSUED'
    CHECK (status IN ('ISSUED','REDEEMED','EXPIRED')),
  PRIMARY KEY (user_id, coupon_id)
);

-- Withdrawals with reserve lifecycle (PDF §16)
CREATE TABLE withdrawals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  idempotency_key TEXT UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  status TEXT NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','APPROVED','PROCESSING','PAID','FAILED','REJECTED')),
  provider_reference TEXT,
  payout_type TEXT NOT NULL CHECK (payout_type IN ('BANK_ACCOUNT','PAYTM')),
  payout_details JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ
);
CREATE INDEX idx_withdrawals_status ON withdrawals(status);

-- Server-side config (PDF §18: no hardcoded reward values)
CREATE TABLE app_config (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO app_config (key, value) VALUES
  ('min_withdrawal', '{"amount": 50.00, "currency": "INR"}'),
  ('daily_limit', '{"amount": 1000.00, "currency": "INR"}'),
  ('task_cooldown_minutes', '{"value": 60}'),
  ('mcq_count', '{"value": 10}'),
  ('reward_mcq', '{"amount": 1.50, "currency": "INR"}'),
  ('reward_ad', '{"amount": 2.00, "currency": "INR"}')
ON CONFLICT (key) DO NOTHING;
