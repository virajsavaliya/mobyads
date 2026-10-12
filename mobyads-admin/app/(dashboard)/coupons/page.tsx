"use client";

import * as React from "react";
import { Ticket, Search, Plus } from "lucide-react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { EmptyState } from "@/components/shared/EmptyState";
import { formatCurrency, formatDate } from "@/lib/utils";

type CouponStatus = "ACTIVE" | "DISABLED" | "EXPIRED";

interface AdminCoupon {
  id: string;
  code: string;
  title: string;
  value: number;
  expiryDate: string;
  status: CouponStatus;
  redeemedCount: number;
}

const SEED: AdminCoupon[] = [
  {
    id: "cpn_01",
    code: "MOBY100",
    title: "₹100 Cashback Coupon",
    value: 100,
    expiryDate: "2026-10-22",
    status: "ACTIVE",
    redeemedCount: 34,
  },
  {
    id: "cpn_02",
    code: "EARN50",
    title: "₹50 Bonus Coupon",
    value: 50,
    expiryDate: "2026-10-15",
    status: "ACTIVE",
    redeemedCount: 12,
  },
  {
    id: "cpn_03",
    code: "OLD10",
    title: "₹10 Expired Coupon",
    value: 10,
    expiryDate: "2026-09-20",
    status: "EXPIRED",
    redeemedCount: 58,
  },
];

export default function CouponsPage() {
  const [coupons, setCoupons] = React.useState<AdminCoupon[]>(SEED);
  const [searchTerm, setSearchTerm] = React.useState("");
  const [statusFilter, setStatusFilter] = React.useState<string>("ALL");
  const [isCreateOpen, setIsCreateOpen] = React.useState(false);
  const [toastMessage, setToastMessage] = React.useState<string | null>(null);

  // Create form
  const [code, setCode] = React.useState("");
  const [title, setTitle] = React.useState("");
  const [value, setValue] = React.useState("");
  const [expiry, setExpiry] = React.useState("");

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const filtered = coupons.filter((c) => {
    const q = searchTerm.toLowerCase().trim();
    const matches =
      !q ||
      c.code.toLowerCase().includes(q) ||
      c.title.toLowerCase().includes(q);
    return matches && (statusFilter === "ALL" || c.status === statusFilter);
  });

  const codeValid = /^[A-Z0-9]{4,12}$/.test(code.trim().toUpperCase());
  const valueNum = Number(value);
  const formValid =
    codeValid && title.trim().length > 0 && valueNum > 0 && expiry !== "";

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formValid) return;
    const normalized = code.trim().toUpperCase();
    if (coupons.some((c) => c.code === normalized)) {
      showToast(`Code ${normalized} already exists.`);
      return;
    }
    setCoupons((prev) => [
      {
        id: `cpn_${Date.now()}`,
        code: normalized,
        title: title.trim(),
        value: valueNum,
        expiryDate: expiry,
        status: "ACTIVE",
        redeemedCount: 0,
      },
      ...prev,
    ]);
    setCode("");
    setTitle("");
    setValue("");
    setExpiry("");
    setIsCreateOpen(false);
    showToast(`Coupon ${normalized} created.`);
  };

  const setStatus = (id: string, status: CouponStatus) => {
    setCoupons((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status } : c))
    );
    showToast(`Coupon ${status === "ACTIVE" ? "enabled" : "disabled"}.`);
  };

  return (
    <div className="space-y-6 max-w-5xl">
      {toastMessage && (
        <div className="fixed bottom-5 right-5 z-50 flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-3 text-xs font-semibold text-white shadow-xl">
          <span>{toastMessage}</span>
        </div>
      )}

      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Coupons
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Create codes, track expiry and status, monitor redemptions.
          </p>
        </div>
        <Button size="sm" onClick={() => setIsCreateOpen(true)} className="h-9 text-xs">
          <Plus className="mr-2 h-4 w-4" /> Create Coupon
        </Button>
      </div>

      <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 bg-white p-3 rounded-xl border border-slate-200 shadow-2xs">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Search by code or title..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-9 h-9 text-xs sm:text-sm border-slate-200"
          />
        </div>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-[140px] h-9 text-xs">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All Statuses</SelectItem>
            <SelectItem value="ACTIVE">Active</SelectItem>
            <SelectItem value="DISABLED">Disabled</SelectItem>
            <SelectItem value="EXPIRED">Expired</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
        {filtered.length === 0 ? (
          <EmptyState
            icon={Ticket}
            title="No coupons found"
            description="Create a coupon or adjust your search."
          />
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="bg-slate-50/75">
                <TableHead className="font-semibold text-slate-600">Code</TableHead>
                <TableHead className="font-semibold text-slate-600">Title</TableHead>
                <TableHead className="font-semibold text-slate-600">Value</TableHead>
                <TableHead className="font-semibold text-slate-600">Expiry</TableHead>
                <TableHead className="font-semibold text-slate-600">Status</TableHead>
                <TableHead className="font-semibold text-slate-600 text-right">Redeemed</TableHead>
                <TableHead className="font-semibold text-slate-600 text-center w-[100px]">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.map((c) => (
                <TableRow key={c.id} className="hover:bg-slate-50/80">
                  <TableCell>
                    <span className="font-mono text-xs font-bold text-slate-800">
                      {c.code}
                    </span>
                  </TableCell>
                  <TableCell className="text-xs font-semibold text-slate-900">
                    {c.title}
                  </TableCell>
                  <TableCell className="text-xs font-bold text-slate-900">
                    {formatCurrency(c.value)}
                  </TableCell>
                  <TableCell className="text-xs text-slate-500">
                    {formatDate(c.expiryDate)}
                  </TableCell>
                  <TableCell>
                    <StatusBadge status={c.status} />
                  </TableCell>
                  <TableCell className="text-right text-xs font-semibold text-slate-700">
                    {c.redeemedCount}
                  </TableCell>
                  <TableCell className="text-center">
                    {c.status === "ACTIVE" ? (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setStatus(c.id, "DISABLED")}
                        className="h-7 px-2 text-[11px]"
                      >
                        Disable
                      </Button>
                    ) : c.status === "DISABLED" ? (
                      <Button
                        size="sm"
                        onClick={() => setStatus(c.id, "ACTIVE")}
                        className="h-7 px-2 text-[11px]"
                      >
                        Enable
                      </Button>
                    ) : (
                      <span className="text-[11px] text-slate-400">—</span>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </div>

      {isCreateOpen && (
        <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
          <DialogContent className="max-w-md p-6">
            <form onSubmit={handleCreate} className="space-y-4">
              <DialogHeader className="pb-2 border-b border-slate-100">
                <DialogTitle className="text-base font-bold text-slate-900">
                  Create Coupon
                </DialogTitle>
                <DialogDescription className="text-xs text-slate-500">
                  Code 4–12 uppercase letters/digits. Expiry required.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-1.5">
                <Label className="text-xs font-semibold text-slate-700">Code</Label>
                <Input
                  value={code}
                  onChange={(e) => setCode(e.target.value.toUpperCase())}
                  placeholder="e.g. MOBY200"
                  required
                  className="h-9 text-xs font-mono"
                />
                {code !== "" && !codeValid && (
                  <p className="text-[11px] text-red-600">
                    4–12 characters, letters and digits only.
                  </p>
                )}
              </div>
              <div className="space-y-1.5">
                <Label className="text-xs font-semibold text-slate-700">Title</Label>
                <Input
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g. ₹200 Cashback Coupon"
                  required
                  className="h-9 text-xs"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <Label className="text-xs font-semibold text-slate-700">Value (₹)</Label>
                  <Input
                    type="number"
                    min="1"
                    value={value}
                    onChange={(e) => setValue(e.target.value)}
                    required
                    className="h-9 text-xs"
                  />
                </div>
                <div className="space-y-1.5">
                  <Label className="text-xs font-semibold text-slate-700">Expiry</Label>
                  <Input
                    type="date"
                    value={expiry}
                    onChange={(e) => setExpiry(e.target.value)}
                    required
                    className="h-9 text-xs"
                  />
                </div>
              </div>
              <DialogFooter className="pt-2 gap-2">
                <Button type="button" variant="outline" size="sm" onClick={() => setIsCreateOpen(false)} className="text-xs">
                  Cancel
                </Button>
                <Button type="submit" size="sm" disabled={!formValid} className="text-xs">
                  Create
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
