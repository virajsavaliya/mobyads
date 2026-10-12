import { cn } from "@/lib/utils";
import { ShieldCheck } from "lucide-react";

interface StatusBadgeProps {
  status: string;
  className?: string;
}

export function StatusBadge({ status, className }: StatusBadgeProps) {
  const normalized = status.toUpperCase().trim();

  // Verification Badges (Icon + Tag)
  if (normalized === "VERIFIED") {
    return (
      <span
        className={cn(
          "inline-flex items-center gap-1 rounded-md border border-blue-200 bg-blue-50 px-2 py-0.5 text-xs font-semibold text-blue-700",
          className
        )}
      >
        <ShieldCheck className="h-3 w-3 text-blue-600" />
        Verified
      </span>
    );
  }

  if (normalized === "UNVERIFIED") {
    return (
      <span
        className={cn(
          "inline-flex items-center gap-1 rounded-md border border-dashed border-slate-300 bg-slate-50 px-2 py-0.5 text-xs font-medium text-slate-500",
          className
        )}
      >
        Unverified
      </span>
    );
  }

  // Account Status Badges (Pill)
  let colorClasses = "bg-slate-100 text-slate-700 border-slate-200";
  let label = status;

  switch (normalized) {
    // 1. Green (Good / Success / Active)
    case "NORMAL":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Normal";
      break;
    case "ACTIVE":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Active";
      break;
    case "APPROVED":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Approved";
      break;
    case "PROCESSED":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Processed";
      break;
    case "SUCCESS":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Success";
      break;
    case "EASY":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Easy";
      break;

    // 2. Yellow / Amber (Under Review / Pending)
    case "REVIEW":
      colorClasses = "bg-amber-50 text-amber-800 border-amber-200 font-bold";
      label = "Under Review";
      break;
    case "PENDING_REVIEW":
      colorClasses = "bg-amber-50 text-amber-800 border-amber-200 font-bold";
      label = "Pending Review";
      break;
    case "PENDING":
      colorClasses = "bg-amber-50 text-amber-700 border-amber-200";
      label = "Pending";
      break;
    case "AVAILABLE":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Available";
      break;
    case "WITHDRAWN":
      colorClasses = "bg-blue-50 text-blue-800 border-blue-200";
      label = "Withdrawn";
      break;
    case "REVERSED":
      colorClasses = "bg-slate-100 text-slate-600 border-slate-200";
      label = "Reversed";
      break;
    case "PROCESSING":
      colorClasses = "bg-blue-50 text-blue-700 border-blue-200";
      label = "Processing";
      break;
    case "PAID":
      colorClasses = "bg-emerald-50 text-emerald-700 border-emerald-200";
      label = "Paid";
      break;
    case "MEDIUM":
      colorClasses = "bg-amber-50 text-amber-700 border-amber-200";
      label = "Medium";
      break;

    // 3. Red (Blocked / Banned / Rejected / Hard)
    case "BLOCKED":
      colorClasses = "bg-red-50 text-red-700 border-red-200 font-bold";
      label = "Blocked";
      break;
    case "BANNED":
      colorClasses = "bg-red-50 text-red-700 border-red-200 font-bold";
      label = "Banned";
      break;
    case "REJECTED":
      colorClasses = "bg-red-50 text-red-700 border-red-200";
      label = "Rejected";
      break;
    case "FAILED":
      colorClasses = "bg-red-50 text-red-700 border-red-200";
      label = "Failed";
      break;
    case "HARD":
      colorClasses = "bg-red-50 text-red-700 border-red-200";
      label = "Hard";
      break;

    // 4. Category Tags
    case "TECH":
    case "SCIENCE":
    case "GENERAL":
    case "BUSINESS":
    case "SPORTS":
    case "HISTORY":
    case "CURRENT_AFFAIRS":
      colorClasses = "bg-blue-50 text-blue-700 border-blue-100";
      label = status.replace("_", " ");
      break;

    // 5. Neutral
    case "RETIRED":
      colorClasses = "bg-slate-100 text-slate-600 border-slate-200";
      label = "Retired";
      break;
    case "EXPIRED":
      colorClasses = "bg-slate-100 text-slate-600 border-slate-200";
      label = "Expired";
      break;
    case "DISABLED":
      colorClasses = "bg-slate-100 text-slate-500 border-slate-200";
      label = "Disabled";
      break;

    default:
      colorClasses = "bg-slate-100 text-slate-700 border-slate-200";
      label = status;
      break;
  }

  return (
    <span
      className={cn(
        "inline-flex items-center rounded-md border px-2 py-0.5 text-xs font-semibold transition-colors",
        colorClasses,
        className
      )}
    >
      {label}
    </span>
  );
}
