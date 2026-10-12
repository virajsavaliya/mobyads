"use client";

import * as React from "react";
import {
  Tv,
  Search,
  ShieldCheck,
  Zap,
  RefreshCw,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { EmptyState } from "@/components/shared/EmptyState";
import { mockAdImpressions } from "@/lib/mock-data";
import { AdImpression } from "@/lib/types";
import { formatCurrency, formatDate } from "@/lib/utils";

export default function AdsPage() {
  const [impressions] = React.useState<AdImpression[]>(mockAdImpressions);
  const [searchTerm, setSearchTerm] = React.useState("");
  const [typeFilter, setTypeFilter] = React.useState<string>("ALL");
  const [page, setPage] = React.useState(1);
  const pageSize = 8;

  const filteredItems = React.useMemo(() => {
    return impressions.filter((imp) => {
      const q = searchTerm.toLowerCase().trim();
      const matchesSearch =
        !q ||
        imp.userName.toLowerCase().includes(q) ||
        imp.id.toLowerCase().includes(q) ||
        imp.placementId.toLowerCase().includes(q);

      const matchesType = typeFilter === "ALL" || imp.adType === typeFilter;

      return matchesSearch && matchesType;
    });
  }, [impressions, searchTerm, typeFilter]);

  const totalPages = Math.ceil(filteredItems.length / pageSize) || 1;
  const paginatedItems = filteredItems.slice(
    (page - 1) * pageSize,
    page * pageSize
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">
              Ad Placements & SSV Verification
            </h1>
            <span className="rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-bold text-emerald-700 border border-emerald-200">
              SSV Active
            </span>
          </div>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Server-side verification callbacks from Google AdMob and configured ad network units.
          </p>
        </div>

        <Button variant="outline" size="sm" className="h-9 text-xs">
          <RefreshCw className="mr-2 h-3.5 w-3.5 text-slate-500" /> Refresh Logs
        </Button>
      </div>

      {/* 3 Metric Cards */}
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-3">
        <Card className="border-slate-200 shadow-2xs">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500">
              Rewarded Video (SSV)
            </CardTitle>
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
              <Zap className="h-3.5 w-3.5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-xl font-bold text-slate-900">₹2.00 / completion</div>
            <p className="text-xs text-emerald-600 font-medium mt-1 flex items-center gap-1">
              <ShieldCheck className="h-3 w-3" /> Cryptographically Verified
            </p>
          </CardContent>
        </Card>

        <Card className="border-slate-200 shadow-2xs">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500">
              Interstitial Transitions
            </CardTitle>
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
              <Tv className="h-3.5 w-3.5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-xl font-bold text-slate-900">₹1.00 / view</div>
            <p className="text-xs text-slate-500 mt-1">Between Quiz Tasks</p>
          </CardContent>
        </Card>

        <Card className="border-slate-200 shadow-2xs">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-semibold uppercase tracking-wider text-slate-500">
              Active Placements
            </CardTitle>
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-purple-50 text-purple-600">
              <ShieldCheck className="h-3.5 w-3.5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-xl font-bold text-slate-900">4 Units Active</div>
            <p className="text-xs text-slate-500 mt-1">
              AdMob Test IDs{" "}
              <span className="ml-1 rounded bg-amber-50 px-1.5 py-0.5 text-[10px] font-bold text-amber-700 border border-amber-200">
                TEST
              </span>
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-white p-3 rounded-xl border border-slate-200 shadow-2xs">
        {/* Search Field */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Search by user, impression ID, or placement ID..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setPage(1);
            }}
            className="pl-9 h-9 text-xs sm:text-sm border-slate-200"
          />
        </div>

        {/* Type Filter */}
        <div className="flex items-center gap-2">
          <Select
            value={typeFilter}
            onValueChange={(val) => {
              setTypeFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[150px] h-9 text-xs">
              <SelectValue placeholder="Ad Type" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Ad Types</SelectItem>
              <SelectItem value="REWARDED">Rewarded Video</SelectItem>
              <SelectItem value="INTERSTITIAL">Interstitial</SelectItem>
              <SelectItem value="BANNER">Banner</SelectItem>
            </SelectContent>
          </Select>

          {(searchTerm || typeFilter !== "ALL") && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setSearchTerm("");
                setTypeFilter("ALL");
                setPage(1);
              }}
              className="h-9 px-2 text-xs text-slate-500 hover:text-slate-900"
            >
              Reset
            </Button>
          )}
        </div>
      </div>

      {/* Data Table */}
      <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
        {paginatedItems.length === 0 ? (
          <EmptyState
            icon={Tv}
            title="No ad impressions found"
            description="Verified SSV callbacks will appear here in real time."
          />
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="bg-slate-50/75">
                <TableHead className="font-semibold text-slate-600">Impression ID</TableHead>
                <TableHead className="font-semibold text-slate-600">User Account</TableHead>
                <TableHead className="font-semibold text-slate-600">Ad Type</TableHead>
                <TableHead className="font-semibold text-slate-600">SSV Verification</TableHead>
                <TableHead className="font-semibold text-slate-600">Reward Credited</TableHead>
                <TableHead className="font-semibold text-slate-600">Placement ID</TableHead>
                <TableHead className="font-semibold text-slate-600">Timestamp</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {paginatedItems.map((imp) => (
                <TableRow key={imp.id} className="hover:bg-slate-50/80 transition-colors">
                  <TableCell>
                    <span className="font-mono text-xs font-bold text-slate-800">
                      {imp.id}
                    </span>
                  </TableCell>

                  <TableCell>
                    <span className="font-semibold text-slate-900 text-sm">
                      {imp.userName}
                    </span>
                  </TableCell>

                  <TableCell>
                    <StatusBadge status={imp.adType} />
                  </TableCell>

                  <TableCell>
                    <div className="flex items-center gap-1.5 text-xs text-emerald-700 font-semibold">
                      <ShieldCheck className="h-4 w-4 text-emerald-600 shrink-0" />
                      <span>Verified</span>
                    </div>
                  </TableCell>

                  <TableCell>
                    <span className="font-bold text-emerald-700 text-sm">
                      +{formatCurrency(imp.rewardAmount)}
                    </span>
                  </TableCell>

                  <TableCell>
                    <span className="font-mono text-[11px] text-slate-500">
                      {imp.placementId}
                    </span>
                  </TableCell>

                  <TableCell>
                    <span className="text-xs text-slate-500">{formatDate(imp.createdAt)}</span>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </div>

      {/* Pagination Footer */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between px-2 pt-1">
          <p className="text-xs text-slate-500 font-medium">
            Showing {(page - 1) * pageSize + 1}–{Math.min(page * pageSize, filteredItems.length)} of{" "}
            {filteredItems.length} impressions
          </p>
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page === 1}
              className="h-8 px-2.5 text-xs"
            >
              <ChevronLeft className="h-4 w-4 mr-1" /> Prev
            </Button>
            <span className="text-xs font-semibold text-slate-700 px-2">
              {page} / {totalPages}
            </span>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
              className="h-8 px-2.5 text-xs"
            >
              Next <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
