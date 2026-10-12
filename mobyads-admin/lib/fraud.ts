import { mockUsers } from "./mock-data";
import type { User } from "./types/index";

export interface FraudAlert {
  id: string;
  severity: "HIGH" | "MEDIUM";
  title: string;
  detail: string;
  userId?: string;
  userName?: string;
}

// Duplicate payout-destination reuse across accounts (PDF §17).
function destinationKey(pm: {
  type: string;
  accountNumber?: string;
  paytmNumber?: string;
}): string | null {
  if (pm.type === "BANK_ACCOUNT" && pm.accountNumber) {
    return `bank:${pm.accountNumber}`;
  }
  if (pm.type === "PAYTM" && pm.paytmNumber) {
    return `paytm:${pm.paytmNumber}`;
  }
  return null;
}

export function getFraudAlerts(users: User[] = mockUsers): FraudAlert[] {
  const alerts: FraudAlert[] = [];

  for (const u of users) {
    if (u.accountStatus === "REVIEW") {
      alerts.push({
        id: `review-${u.id}`,
        severity: "MEDIUM",
        title: `${u.name} flagged for review`,
        detail: "Account in REVIEW state awaiting compliance inspection.",
        userId: u.id,
        userName: u.name,
      });
    }
    if (u.accountStatus === "BLOCKED") {
      alerts.push({
        id: `blocked-${u.id}`,
        severity: "HIGH",
        title: `${u.name} blocked`,
        detail: "Blocked account — verify no new task or payout activity.",
        userId: u.id,
        userName: u.name,
      });
    }
    if (
      u.verificationStatus === "UNVERIFIED" &&
      (u.pendingBalance ?? 0) > 0
    ) {
      alerts.push({
        id: `unverified-pending-${u.id}`,
        severity: "MEDIUM",
        title: `${u.name} holds pending balance while unverified`,
        detail: "Unverified identity with funds in fraud-check window.",
        userId: u.id,
        userName: u.name,
      });
    }
  }

  const seen = new Map<string, { userId: string; userName: string }>();
  for (const u of users) {
    for (const pm of u.payoutMethods ?? []) {
      const key = destinationKey(pm);
      if (!key) continue;
      const first = seen.get(key);
      if (first && first.userId !== u.id) {
        alerts.push({
          id: `reuse-${key}`,
          severity: "HIGH",
          title: "Payout destination reused across accounts",
          detail: `Shared by ${first.userName} and ${u.name}. Possible multi-account ring.`,
          userId: u.id,
          userName: u.name,
        });
      } else if (!first) {
        seen.set(key, { userId: u.id, userName: u.name });
      }
    }
  }

  return alerts;
}
