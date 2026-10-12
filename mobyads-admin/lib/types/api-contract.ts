// M2-M3 shared contract mirror (see ../../backend/openapi.yaml).
// Wire format is snake_case; this file exposes camelCase app types + translators.
// Correct answers NEVER appear in client types (PDF §7).

export type ServerAccountStatus = "NORMAL" | "REVIEW" | "BLOCKED";
export type ServerVerificationStatus = "VERIFIED" | "UNVERIFIED";
export type LedgerStatus =
  | "PENDING"
  | "AVAILABLE"
  | "WITHDRAWN"
  | "REVERSED"
  | "FAILED";
export type ServerWithdrawalStatus =
  | "PENDING"
  | "APPROVED"
  | "PROCESSING"
  | "PAID"
  | "FAILED"
  | "REJECTED";

export interface ServerUser {
  id: string;
  name: string;
  email: string;
  phone?: string;
  country?: string;
  accountStatus: ServerAccountStatus;
  verificationStatus: ServerVerificationStatus;
  createdAt: string;
}

export interface PublicQuestion {
  id: string;
  text: string;
  options: [string, string, string, string];
  category: string;
  rewardAmount: number;
  rewardCurrency: string;
}

export interface LedgerTransaction {
  id: string;
  userId: string;
  sourceType: "MCQ" | "AD_REWARD" | "DAILY" | "REFERRAL" | "WITHDRAWAL" | "COUPON";
  sourceId: string;
  amount: number;
  currency: string;
  status: LedgerStatus;
  availableAt: string;
  createdAt: string;
}

export interface ContractWithdrawal {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  status: ServerWithdrawalStatus;
  providerReference: string | null;
  payoutType: "BANK_ACCOUNT" | "PAYTM";
}

export interface PublicConfig {
  minWithdrawal: number;
  dailyLimit: number;
  taskCooldownMinutes: number;
  mcqCount: number;
  rewardMcq: number;
  rewardAd: number;
  currency: string;
}

// snake_case -> camelCase translators (backend is snake_case)
function str(v: unknown, fb = ""): string {
  return typeof v === "string" ? v : fb;
}
function num(v: unknown, fb = 0): number {
  return typeof v === "number" ? v : fb;
}

export function toPublicQuestion(j: Record<string, unknown>): PublicQuestion {
  const opts = Array.isArray(j["options"])
    ? (j["options"] as unknown[]).map(String)
    : [];
  while (opts.length < 4) opts.push("");
  return {
    id: str(j["id"]),
    text: str(j["text"]),
    options: [opts[0], opts[1], opts[2], opts[3]],
    category: str(j["category"], "GENERAL"),
    rewardAmount: num(j["reward_amount"]),
    rewardCurrency: str(j["reward_currency"], "INR"),
  };
}

export function toLedgerTransaction(
  j: Record<string, unknown>,
): LedgerTransaction {
  return {
    id: str(j["id"]),
    userId: str(j["user_id"]),
    sourceType: (str(j["source_type"], "MCQ") as LedgerTransaction["sourceType"]),
    sourceId: str(j["source_id"]),
    amount: num(j["amount"]),
    currency: str(j["currency"], "INR"),
    status: (str(j["status"], "PENDING") as LedgerStatus),
    availableAt: str(j["available_at"]),
    createdAt: str(j["created_at"]),
  };
}

// PDF §7 guard: strip admin-only answer fields before anything public.
// Returns true when payload is safe to send to Flutter clients.
export function isPublicQuestionSafe(j: Record<string, unknown>): boolean {
  return (
    j["correct_option_index"] === undefined &&
    j["correctIndex"] === undefined &&
    j["correct_answer"] === undefined
  );
}

export function stripAnswerForPublic(
  j: Record<string, unknown>,
): Record<string, unknown> {
  const { correct_option_index: _a, correctIndex: _b, correct_answer: _c, ...rest } =
    j as Record<string, unknown> & {
      correct_option_index?: unknown;
      correctIndex?: unknown;
      correct_answer?: unknown;
    };
  void _a;
  void _b;
  void _c;
  return rest;
}

// PDF §8/§14: derive wallet buckets from ledger (admin audit helper).
export function summarizeLedger(txns: LedgerTransaction[]): {
  available: number;
  pending: number;
  withdrawn: number;
} {
  let available = 0;
  let pending = 0;
  let withdrawn = 0;
  for (const t of txns) {
    if (t.status === "AVAILABLE") available += t.amount;
    else if (t.status === "PENDING") pending += t.amount;
    else if (t.status === "WITHDRAWN") withdrawn += t.amount;
  }
  return { available, pending, withdrawn };
}

// PDF §11 SSV audit checklist: backend must verify all of these.
export interface SsvCallback {
  sessionId?: string;
  providerTransactionId?: string;
  adUnitId?: string;
  signatureValid?: boolean;
  alreadyProcessed?: boolean;
}

export function ssvChecks(c: SsvCallback): { ok: boolean; failures: string[] } {
  const failures: string[] = [];
  if (!c.sessionId) failures.push("missing session");
  if (!c.providerTransactionId) failures.push("missing provider txn");
  if (c.signatureValid !== true) failures.push("bad signature");
  if (c.alreadyProcessed === true) failures.push("duplicate callback");
  return { ok: failures.length === 0, failures };
}
