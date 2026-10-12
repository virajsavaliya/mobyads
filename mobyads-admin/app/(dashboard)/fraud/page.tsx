"use client";

import * as React from "react";
import Link from "next/link";
import { ShieldAlert, ArrowUpRight } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { EmptyState } from "@/components/shared/EmptyState";
import { getFraudAlerts, FraudAlert } from "@/lib/fraud";

export default function FraudPage() {
  const [alerts] = React.useState<FraudAlert[]>(() => getFraudAlerts());
  const [selected, setSelected] = React.useState<FraudAlert | null>(null);

  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">
          Fraud & Risk
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Review-state accounts, blocked activity, unverified balances, and reused payout destinations.
        </p>
      </div>

      {alerts.length === 0 ? (
        <EmptyState
          icon={ShieldAlert}
          title="No fraud alerts"
          description="No review accounts, blocks, or destination reuse detected."
        />
      ) : (
        <Card className="border-slate-200 shadow-2xs">
          <CardHeader className="p-6 pb-2">
            <CardTitle className="text-base font-bold text-slate-900">
              Open alerts ({alerts.length})
            </CardTitle>
            <CardDescription className="text-xs text-slate-500">
              Select an alert for evidence and account actions.
            </CardDescription>
          </CardHeader>
          <CardContent className="p-6 pt-2">
            <div className="divide-y divide-slate-100">
              {alerts.map((a) => (
                <button
                  key={a.id}
                  onClick={() => setSelected(a)}
                  className="flex w-full items-center justify-between gap-3 py-3 text-left hover:bg-slate-50/60 rounded-lg px-2 cursor-pointer"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <div
                      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${
                        a.severity === "HIGH"
                          ? "bg-red-50 text-red-600"
                          : "bg-amber-50 text-amber-600"
                      }`}
                    >
                      <ShieldAlert className="h-4 w-4" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs sm:text-sm font-semibold text-slate-900 truncate">
                        {a.title}
                      </p>
                      <p className="text-[11px] text-slate-500 truncate">
                        {a.severity} severity
                      </p>
                    </div>
                  </div>
                  <ArrowUpRight className="h-4 w-4 text-slate-400 shrink-0" />
                </button>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {selected && (
        <Dialog open={Boolean(selected)} onOpenChange={(open) => !open && setSelected(null)}>
          <DialogContent className="max-w-md p-6">
            <DialogHeader>
              <div className="flex items-center justify-between gap-2">
                <DialogTitle className="text-base font-bold text-slate-900">
                  Alert detail
                </DialogTitle>
                <StatusBadge status={selected.severity === "HIGH" ? "BLOCKED" : "REVIEW"} />
              </div>
              <DialogDescription className="text-xs text-slate-500 pt-1">
                {selected.title}
              </DialogDescription>
            </DialogHeader>
            <p className="text-xs text-slate-700 pt-2">{selected.detail}</p>
            <div className="flex justify-end gap-2 pt-4">
              <Button variant="outline" size="sm" onClick={() => setSelected(null)} className="text-xs">
                Close
              </Button>
              {selected.userId && (
                <Button size="sm" asChild className="text-xs">
                  <Link href="/users">Open user review</Link>
                </Button>
              )}
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
