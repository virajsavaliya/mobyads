export type AccountStatus = "NORMAL" | "REVIEW" | "BLOCKED";
export type VerificationStatus = "VERIFIED" | "UNVERIFIED";

export type PayoutType = "BANK_ACCOUNT" | "PAYTM";

export interface UserPayoutMethod {
  id: string;
  type: PayoutType;
  holderName: string;
  accountNumber?: string;
  ifscCode?: string;
  bankName?: string;
  paytmNumber?: string;
  isDefault: boolean;
}

export interface UserTransaction {
  id: string;
  title: string;
  type: "EARNING" | "WITHDRAWAL";
  amount: number;
  isCredit: boolean;
  timestamp: string;
  category?: string;
  status: "COMPLETED" | "PENDING" | "FAILED";
}

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  accountStatus: AccountStatus;
  verificationStatus: VerificationStatus;
  balance: number;
  pendingBalance: number;
  totalEarned: number;
  totalWithdrawn: number;
  completedTasksCount: number;
  createdAt: string;
  lastActiveAt: string;
  payoutMethods: UserPayoutMethod[];
  transactions: UserTransaction[];
}

export type QuestionStatus = "ACTIVE" | "RETIRED" | "PENDING_REVIEW";
export type QuestionCategory =
  | "TECH"
  | "SCIENCE"
  | "GENERAL"
  | "BUSINESS"
  | "SPORTS"
  | "HISTORY"
  | "CURRENT_AFFAIRS";
export type QuestionDifficulty = "EASY" | "MEDIUM" | "HARD";

export interface MCQQuestion {
  id: string;
  text: string;
  options: string[];
  correctIndex: number;
  category: QuestionCategory;
  difficulty?: QuestionDifficulty;
  status: QuestionStatus;
  sourceName?: string;
  sourceDate: string;
  expiresAt?: string | null;
  timesAnswered?: number;
  correctRate?: number;
  createdAt: string;
}

export type AdType = "BANNER" | "INTERSTITIAL" | "REWARDED";

export interface AdImpression {
  id: string;
  userId: string;
  userName: string;
  adType: AdType;
  rewardAmount: number;
  ssvVerified: boolean;
  placementId: string;
  ipAddress: string;
  createdAt: string;
}

export type WithdrawalStatus = "PENDING" | "APPROVED" | "REJECTED" | "PROCESSED";

export interface Withdrawal {
  id: string;
  userId: string;
  userName: string;
  userEmail: string;
  amount: number;
  payoutType: PayoutType;
  payoutDetails: {
    holderName: string;
    accountNumber?: string;
    ifscCode?: string;
    bankName?: string;
    paytmNumber?: string;
  };
  status: WithdrawalStatus;
  referenceId: string;
  notes?: string;
  createdAt: string;
  processedAt?: string;
}

export interface DashboardMetrics {
  totalUsers: number;
  usersChange: number;
  activeToday: number;
  totalRevenue: number;
  revenueChange: number;
  totalPayouts: number;
  pendingWithdrawalsCount: number;
  pendingWithdrawalsAmount: number;
  totalImpressions: number;
  avgCompletionRate: number;
}
