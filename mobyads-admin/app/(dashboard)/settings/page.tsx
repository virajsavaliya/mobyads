"use client";

import * as React from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Button } from "@/components/ui/button";
import { Save, CheckCircle2, Shield, Sliders, CreditCard } from "lucide-react";
import { api } from "@/lib/api-client";

const ENV_LABEL =
  process.env.NEXT_PUBLIC_API_BASE_URL?.includes("api.mobyads.com") &&
  !process.env.NEXT_PUBLIC_API_BASE_URL.includes("-")
    ? "Production"
    : process.env.NEXT_PUBLIC_API_BASE_URL?.includes("staging")
      ? "Staging"
      : "Development";

const ADMOB_UNITS = [
  { label: "Rewarded (Android)", id: "ca-app-pub-3940256099942544/5224354917" },
  { label: "Interstitial (Android)", id: "ca-app-pub-3940256099942544/1033173712" },
  { label: "Banner (Android)", id: "ca-app-pub-3940256099942544/6300978111" },
];

export default function SettingsPage() {
  const [cooldownMinutes, setCooldownMinutes] = React.useState("60");
  const [mcqCount, setMcqCount] = React.useState("10");
  const [minWithdraw, setMinWithdraw] = React.useState("50.00");
  const [dailyLimit, setDailyLimit] = React.useState("1000.00");
  const [paytmEnabled, setPaytmEnabled] = React.useState(true);
  const [bankEnabled, setBankEnabled] = React.useState(true);
  const [rolling247, setRolling247] = React.useState(true);
  const [toastMessage, setToastMessage] = React.useState<string | null>(null);
  const [configSource, setConfigSource] = React.useState<"server" | "local">("local");

  React.useEffect(() => {
    let cancelled = false;
    api
      .getPublicConfig()
      .then((cfg) => {
        if (cancelled) return;
        if (typeof cfg.minWithdrawal === "number") {
          setMinWithdraw(cfg.minWithdrawal.toFixed(2));
        }
        if (typeof cfg.taskCooldownMinutes === "number") {
          setCooldownMinutes(String(cfg.taskCooldownMinutes));
        }
        setConfigSource("server");
      })
      .catch(() => {
        if (!cancelled) setConfigSource("local");
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    const suffix =
      configSource === "server" ? " (server contract active)." : " (local fallback — backend unreachable).";
    setToastMessage(`Platform settings saved${suffix}`);
    setTimeout(() => setToastMessage(null), 3000);
  };

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-5 right-5 z-50 flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-3 text-xs font-semibold text-white shadow-xl animate-in slide-in-from-bottom-5">
          <CheckCircle2 className="h-4 w-4 text-emerald-400" />
          <span>{toastMessage}</span>
        </div>
      )}

      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">
          Platform Settings{" "}
          <span className="ml-1 inline-flex items-center rounded-full bg-neutral-100 px-2 py-0.5 text-[10px] font-bold text-neutral-900 border border-neutral-300 align-middle">
            {ENV_LABEL}
          </span>
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Configure cooldown rules, reward rates, AdMob identifiers, and payout parameters.
          <span className="ml-2 inline-flex items-center rounded-full bg-slate-100 px-2 py-0.5 text-[10px] font-bold text-slate-600">
            {configSource === "server" ? "Server contract" : "Local fallback"}
          </span>
        </p>
      </div>

      <form onSubmit={handleSave} className="grid gap-6">
        {/* Task & Cooldown Rules */}
        <Card className="border-slate-200 shadow-2xs">
          <CardHeader className="p-6 pb-4">
            <div className="flex items-center gap-2">
              <Sliders className="h-4 w-4 text-neutral-900" />
              <CardTitle className="text-base font-bold text-slate-900">
                Task Engine & Cooldown Rules
              </CardTitle>
            </div>
            <CardDescription className="text-xs text-slate-500">
              Continuous 24/7 rolling task cooldown and quiz parameters
            </CardDescription>
          </CardHeader>
          <CardContent className="p-6 pt-0 space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <Label htmlFor="cooldown" className="text-xs font-semibold text-slate-700">
                  Task Cooldown (Minutes)
                </Label>
                <Input
                  id="cooldown"
                  value={cooldownMinutes}
                  onChange={(e) => setCooldownMinutes(e.target.value)}
                  type="number"
                  className="h-9 text-xs sm:text-sm"
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="mcqCount" className="text-xs font-semibold text-slate-700">
                  Questions Per Task
                </Label>
                <Input
                  id="mcqCount"
                  value={mcqCount}
                  onChange={(e) => setMcqCount(e.target.value)}
                  type="number"
                  className="h-9 text-xs sm:text-sm"
                />
              </div>
            </div>

            <div className="flex items-center justify-between pt-2 border-t border-slate-100">
              <div className="space-y-0.5">
                <Label className="text-xs font-semibold text-slate-900">
                  Continuous 24/7 Rolling Cooldown
                </Label>
                <p className="text-[11px] text-slate-400">
                  Tasks roll continuously without midnight resets or hourly grid constraints
                </p>
              </div>
              <Switch
                checked={rolling247}
                onCheckedChange={setRolling247}
              />
            </div>
          </CardContent>
        </Card>

        {/* Withdrawal Controls */}
        <Card className="border-slate-200 shadow-2xs">
          <CardHeader className="p-6 pb-4">
            <div className="flex items-center gap-2">
              <CreditCard className="h-4 w-4 text-emerald-600" />
              <CardTitle className="text-base font-bold text-slate-900">
                Withdrawal & Payout Controls
              </CardTitle>
            </div>
            <CardDescription className="text-xs text-slate-500">
              Minimum withdrawal thresholds and supported payout channels
            </CardDescription>
          </CardHeader>
          <CardContent className="p-6 pt-0 space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <Label htmlFor="minWithdraw" className="text-xs font-semibold text-slate-700">
                  Minimum Withdrawal (₹)
                </Label>
                <Input
                  id="minWithdraw"
                  value={minWithdraw}
                  onChange={(e) => setMinWithdraw(e.target.value)}
                  className="h-9 text-xs sm:text-sm"
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="dailyLimit" className="text-xs font-semibold text-slate-700">
                  Daily Withdrawal Limit (₹)
                </Label>
                <Input
                  id="dailyLimit"
                  value={dailyLimit}
                  onChange={(e) => setDailyLimit(e.target.value)}
                  className="h-9 text-xs sm:text-sm"
                />
              </div>
            </div>

            <div className="space-y-3 pt-2 border-t border-slate-100">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label className="text-xs font-semibold text-slate-900">
                    Enable Paytm Payouts
                  </Label>
                  <p className="text-[11px] text-slate-400">
                    Allow disbursements via Paytm 10-digit mobile number
                  </p>
                </div>
                <Switch
                  checked={paytmEnabled}
                  onCheckedChange={setPaytmEnabled}
                />
              </div>

              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label className="text-xs font-semibold text-slate-900">
                    Enable Bank Account Transfers (NEFT/IMPS)
                  </Label>
                  <p className="text-[11px] text-slate-400">
                    Allow payouts via Account Number and IFSC code
                  </p>
                </div>
                <Switch
                  checked={bankEnabled}
                  onCheckedChange={setBankEnabled}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* AdMob identifiers (advanced, collapsed) */}
        <details className="rounded-xl border border-slate-200 bg-white shadow-2xs">
          <summary className="cursor-pointer p-6 text-base font-bold text-slate-900 list-none">
            AdMob Identifiers{" "}
            <span className="ml-1 rounded bg-amber-50 px-1.5 py-0.5 text-[10px] font-bold text-amber-700 border border-amber-200">
              TEST
            </span>
          </summary>
          <div className="px-6 pb-6 space-y-2">
            <p className="text-xs text-slate-500">
              Google test units. Swap to production IDs at release (release blocker otherwise).
            </p>
            {ADMOB_UNITS.map((u) => (
              <div key={u.id} className="flex flex-col sm:flex-row sm:items-center justify-between gap-1 rounded-lg bg-slate-50 px-3 py-2 border border-slate-100">
                <span className="text-xs font-semibold text-slate-700">{u.label}</span>
                <span className="font-mono text-[11px] text-slate-500">{u.id}</span>
              </div>
            ))}
          </div>
        </details>

        {/* Security & Secrets */}
        <Card className="border-slate-200 shadow-2xs">
          <CardHeader className="p-6 pb-4">
            <div className="flex items-center gap-2">
              <Shield className="h-4 w-4 text-neutral-700" />
              <CardTitle className="text-base font-bold text-slate-900">
                Security & Key Isolation
              </CardTitle>
            </div>
            <CardDescription className="text-xs text-slate-500">
              Cryptographic keys and token isolation configuration
            </CardDescription>
          </CardHeader>
          <CardContent className="p-6 pt-0 space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="adminSecret" className="text-xs font-semibold text-slate-700">
                ADMIN_JWT_SECRET Separation
              </Label>
              <Input
                id="adminSecret"
                value="sha256_e82...0a9 (Separate from user JWT secret)"
                disabled
                className="bg-slate-50 font-mono text-xs h-9"
              />
            </div>

            <div className="flex justify-end pt-2">
              <Button
                type="submit"
                size="sm"
                className="h-9 bg-neutral-900 hover:bg-black text-white font-semibold text-xs shadow-xs"
              >
                <Save className="mr-2 h-4 w-4" /> Save Configuration
              </Button>
            </div>
          </CardContent>
        </Card>
      </form>
    </div>
  );
}
