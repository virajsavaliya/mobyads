import Link from "next/link";
import {
  Users,
  CreditCard,
  HelpCircle,
  Clock,
  Activity,
  ArrowUpRight,
  TrendingUp,
  FileQuestion,
  UserPlus,
  Tv,
  CheckCircle2,
} from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { formatCurrency } from "@/lib/utils";
import { getFraudAlerts } from "@/lib/fraud";

interface ActivityItem {
  id: string;
  icon: React.ElementType;
  iconColor: string;
  bgColor: string;
  title: string;
  subtitle: string;
  timeAgo: string;
}

const RECENT_ACTIVITIES: ActivityItem[] = [
  {
    id: "act_1",
    icon: CreditCard,
    iconColor: "text-amber-600",
    bgColor: "bg-amber-50",
    title: "New withdrawal request — ₹500.00",
    subtitle: "Alex Johnson requested bank transfer (Ref: WDR-847291)",
    timeAgo: "12 mins ago",
  },
  {
    id: "act_2",
    icon: FileQuestion,
    iconColor: "text-neutral-900",
    bgColor: "bg-neutral-100",
    title: "1,200 questions uploaded",
    subtitle: "Batch ingestion to General & Science categories completed",
    timeAgo: "45 mins ago",
  },
  {
    id: "act_3",
    icon: UserPlus,
    iconColor: "text-emerald-600",
    bgColor: "bg-emerald-50",
    title: "New user registered",
    subtitle: "Priya Sharma (+91 9876543291) joined via mobile app",
    timeAgo: "1 hr ago",
  },
  {
    id: "act_4",
    icon: CheckCircle2,
    iconColor: "text-neutral-700",
    bgColor: "bg-neutral-100",
    title: "Paytm withdrawal approved — ₹100.00",
    subtitle: "Instant mobile wallet disbursement executed successfully",
    timeAgo: "2 hrs ago",
  },
  {
    id: "act_5",
    icon: Tv,
    iconColor: "text-neutral-700",
    bgColor: "bg-neutral-100",
    title: "SSV rewarded ad verified",
    subtitle: "Cryptographic callback validated from AdMob network",
    timeAgo: "3 hrs ago",
  },
];

const NEEDS_ATTENTION = [
  {
    id: "att_1",
    title: "14 withdrawals awaiting approval (₹6,450.00)",
    href: "/withdrawals",
  },
  {
    id: "att_2",
    title: "Accounts flagged for review",
    href: "/users",
  },
];

export default function DashboardOverviewPage() {
  const fraudCount = getFraudAlerts().length;
  const stats = [
    {
      title: "Total Users",
      value: "14,250",
      change: "+12.4%",
      changeType: "positive",
      description: "Registered participants",
      icon: Users,
      iconBg: "bg-neutral-100 text-neutral-900",
    },
    {
      title: "Active Today",
      value: "3,840",
      change: "+8.1%",
      changeType: "positive",
      description: "Solving 24/7 quiz tasks",
      icon: Activity,
      iconBg: "bg-emerald-50 text-emerald-600",
    },
    {
      title: "Pending Withdrawals",
      value: "14",
      change: "₹6,450.00",
      changeType: "warning",
      description: "Awaiting approval",
      icon: Clock,
      iconBg: "bg-amber-50 text-amber-600",
    },
    {
      title: "Total Paid Out This Month",
      value: formatCurrency(94200),
      change: "+18.2%",
      changeType: "positive",
      description: "Bank & Paytm transfers",
      icon: CreditCard,
      iconBg: "bg-neutral-100 text-neutral-700",
    },
  ];

  return (
    <div className="space-y-8">
      {/* Top Banner / Welcome */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-bold tracking-tight text-slate-900">
            Welcome back, Administrator
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            System status is healthy. Continuous task engine and SSV endpoints are operating normally.
          </p>
        </div>
        <div className="flex items-center gap-2.5">
          <Button variant="outline" size="sm" asChild>
            <Link href="/withdrawals">
              Review Payouts ({14})
            </Link>
          </Button>
          <Button size="sm" asChild>
            <Link href="/mcq">
              Add Questions
            </Link>
          </Button>
        </div>
      </div>

      {/* Row of 4 core KPI cards (Questions in Bank lives in Quick Management) */}
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat, idx) => {
          const Icon = stat.icon;
          return (
            <Card key={idx} className="border-slate-200 shadow-2xs hover:shadow-xs transition-shadow">
              <CardHeader className="flex flex-row items-center justify-between pb-2 space-y-0">
                <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500 truncate">
                  {stat.title}
                </CardTitle>
                <div className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-lg ${stat.iconBg}`}>
                  <Icon className="h-3.5 w-3.5" />
                </div>
              </CardHeader>
              <CardContent>
                <div className="text-xl sm:text-2xl font-bold text-slate-900 leading-tight">
                  {stat.value}
                </div>
                <div className="flex items-center text-xs mt-1 font-medium">
                  {stat.changeType === "positive" && (
                    <span className="flex items-center text-emerald-600">
                      <TrendingUp className="h-3 w-3 mr-0.5" />
                      {stat.change}
                    </span>
                  )}
                  {stat.changeType === "warning" && (
                    <span className="text-amber-700 font-semibold">
                      {stat.change}
                    </span>
                  )}
                  {stat.changeType === "neutral" && (
                    <span className="text-slate-600">
                      {stat.change} added
                    </span>
                  )}
                  <span className="text-slate-400 ml-1.5 truncate">
                    · {stat.description}
                  </span>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Needs attention: withdrawals queue, reviews, fraud alerts */}
      <Card className="border-amber-200 bg-amber-50/50 shadow-2xs">
        <CardContent className="py-3">
          <div className="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-6">
            <span className="text-xs font-bold uppercase tracking-wider text-amber-800 shrink-0">
              Needs attention
            </span>
            <div className="flex flex-col sm:flex-row gap-1.5 sm:gap-6 flex-1">
              {NEEDS_ATTENTION.map((item) => (
                <Link
                  key={item.id}
                  href={item.href}
                  className="text-xs font-semibold text-slate-800 hover:text-black underline-offset-2 hover:underline"
                >
                  {item.title} →
                </Link>
              ))}
              <Link
                href="/fraud"
                className="text-xs font-semibold text-slate-800 hover:text-black underline-offset-2 hover:underline"
              >
                {fraudCount === 0
                  ? "No fraud alerts →"
                  : `${fraudCount} fraud alerts →`}
              </Link>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Recent Activity & Quick Navigation */}
      <div className="grid gap-6 grid-cols-1 lg:grid-cols-3">
        {/* Recent Activity List */}
        <Card className="lg:col-span-2 border-slate-200 shadow-2xs">
          <CardHeader className="flex flex-row items-center justify-between pb-4">
            <div>
              <CardTitle className="text-base font-bold text-slate-900">
                Recent System Activity
              </CardTitle>
              <CardDescription className="text-xs text-slate-500">
                Real-time operational events from users, quiz tasks, and ad networks
              </CardDescription>
            </div>
            <span className="text-xs text-slate-400 font-mono">Live Stream</span>
          </CardHeader>
          <CardContent>
            <div className="divide-y divide-slate-100">
              {RECENT_ACTIVITIES.map((act) => {
                const Icon = act.icon;
                return (
                  <div
                    key={act.id}
                    className="flex items-start gap-3.5 py-3 first:pt-0 last:pb-0 hover:bg-slate-50/60 transition-colors rounded-lg px-2"
                  >
                    <div
                      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${act.bgColor} ${act.iconColor} mt-0.5`}
                    >
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between gap-2">
                        <p className="text-xs sm:text-sm font-semibold text-slate-900 truncate">
                          {act.title}
                        </p>
                        <span className="text-[11px] text-slate-400 shrink-0 font-medium">
                          {act.timeAgo}
                        </span>
                      </div>
                      <p className="text-xs text-slate-500 truncate mt-0.5">
                        {act.subtitle}
                      </p>
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>

        {/* Quick Links / Status Card */}
        <Card className="border-slate-200 shadow-2xs flex flex-col">
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-bold text-slate-900">
              Quick Management
            </CardTitle>
            <CardDescription className="text-xs text-slate-500">
              Direct access to critical admin consoles
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2 flex-1">
            <Link
              href="/withdrawals"
              className="flex items-center justify-between p-3 rounded-lg border border-slate-100 bg-slate-50/70 hover:bg-neutral-100/60 hover:border-neutral-300 transition-colors group"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-md bg-amber-100 text-amber-700">
                  <Clock className="h-4 w-4" />
                </div>
                <div>
                  <div className="text-xs font-bold text-slate-900 group-hover:text-black">
                    Withdrawal Approvals
                  </div>
                  <div className="text-[11px] text-slate-500">14 pending payouts</div>
                </div>
              </div>
              <ArrowUpRight className="h-4 w-4 text-slate-400 group-hover:text-neutral-900" />
            </Link>

            <Link
              href="/users"
              className="flex items-center justify-between p-3 rounded-lg border border-slate-100 bg-slate-50/70 hover:bg-neutral-100/60 hover:border-neutral-300 transition-colors group"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-md bg-neutral-200 text-black">
                  <Users className="h-4 w-4" />
                </div>
                <div>
                  <div className="text-xs font-bold text-slate-900 group-hover:text-black">
                    User Accounts
                  </div>
                  <div className="text-[11px] text-slate-500">Inspect balances & bans</div>
                </div>
              </div>
              <ArrowUpRight className="h-4 w-4 text-slate-400 group-hover:text-neutral-900" />
            </Link>

            <Link
              href="/mcq"
              className="flex items-center justify-between p-3 rounded-lg border border-slate-100 bg-slate-50/70 hover:bg-neutral-100/60 hover:border-neutral-300 transition-colors group"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-md bg-neutral-200 text-neutral-800">
                  <HelpCircle className="h-4 w-4" />
                </div>
                <div>
                  <div className="text-xs font-bold text-slate-900 group-hover:text-black">
                    MCQ Question Pool
                  </div>
                  <div className="text-[11px] text-slate-500">5,420 questions active</div>
                </div>
              </div>
              <ArrowUpRight className="h-4 w-4 text-slate-400 group-hover:text-neutral-900" />
            </Link>

            <Link
              href="/ads"
              className="flex items-center justify-between p-3 rounded-lg border border-slate-100 bg-slate-50/70 hover:bg-neutral-100/60 hover:border-neutral-300 transition-colors group"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-md bg-neutral-200 text-neutral-800">
                  <Tv className="h-4 w-4" />
                </div>
                <div>
                  <div className="text-xs font-bold text-slate-900 group-hover:text-black">
                    SSV Verification Logs
                  </div>
                  <div className="text-[11px] text-slate-500">Google AdMob callbacks</div>
                </div>
              </div>
              <ArrowUpRight className="h-4 w-4 text-slate-400 group-hover:text-neutral-900" />
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
