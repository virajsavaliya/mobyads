"use client";

import * as React from "react";
import { ScrollText } from "lucide-react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { EmptyState } from "@/components/shared/EmptyState";
import { formatDate } from "@/lib/utils";

interface AuditEntry {
  id: string;
  actor: string;
  action: string;
  target: string;
  at: string;
}

const SEED: AuditEntry[] = [
  {
    id: "log_01",
    actor: "admin@mobyads.internal",
    action: "Approved withdrawal WDR-847291",
    target: "Alex Johnson",
    at: "2026-09-01T08:20:00Z",
  },
  {
    id: "log_02",
    actor: "admin@mobyads.internal",
    action: "Blocked account",
    target: "Rahul Verma",
    at: "2026-08-30T12:05:00Z",
  },
  {
    id: "log_03",
    actor: "admin@mobyads.internal",
    action: "Created coupon MOBY100",
    target: "Coupons",
    at: "2026-08-28T09:40:00Z",
  },
  {
    id: "log_04",
    actor: "admin@mobyads.internal",
    action: "Verified account",
    target: "Ananya Patel",
    at: "2026-08-27T15:12:00Z",
  },
];

export default function AuditPage() {
  const [entries] = React.useState<AuditEntry[]>(SEED);

  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">
          Roles & Audit Log
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Immutable record of administrative actions. Entries cannot be edited or deleted.
        </p>
      </div>

      <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
        {entries.length === 0 ? (
          <EmptyState
            icon={ScrollText}
            title="No audit entries"
            description="Administrative actions will appear here."
          />
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="bg-slate-50/75">
                <TableHead className="font-semibold text-slate-600">Actor</TableHead>
                <TableHead className="font-semibold text-slate-600">Action</TableHead>
                <TableHead className="font-semibold text-slate-600">Target</TableHead>
                <TableHead className="font-semibold text-slate-600">Time</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {entries.map((e) => (
                <TableRow key={e.id} className="hover:bg-slate-50/80">
                  <TableCell className="font-mono text-xs text-slate-700">
                    {e.actor}
                  </TableCell>
                  <TableCell className="text-xs font-semibold text-slate-900">
                    {e.action}
                  </TableCell>
                  <TableCell className="text-xs text-slate-600">
                    {e.target}
                  </TableCell>
                  <TableCell className="text-xs text-slate-500">
                    {formatDate(e.at)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </div>
    </div>
  );
}
