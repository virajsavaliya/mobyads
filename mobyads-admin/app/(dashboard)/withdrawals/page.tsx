"use client";

import * as React from "react";
import {
  CreditCard,
  Search,
  CheckCircle,
  XCircle,
  Download,
  Wallet,
  Building2,
  ChevronLeft,
  ChevronRight,
  CheckCircle2,
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { EmptyState } from "@/components/shared/EmptyState";
import { mockWithdrawals, mockUsers } from "@/lib/mock-data";
import { Withdrawal, WithdrawalStatus } from "@/lib/types";
import { formatCurrency, formatDate } from "@/lib/utils";

export default function WithdrawalsPage() {
  const [withdrawals, setWithdrawals] = React.useState<Withdrawal[]>(mockWithdrawals);
  const [searchTerm, setSearchTerm] = React.useState("");
  const [statusFilter, setStatusFilter] = React.useState<string>("ALL");
  const [typeFilter, setTypeFilter] = React.useState<string>("ALL");
  const [page, setPage] = React.useState(1);
  const pageSize = 8;

  // Detail Modal & Action Confirmation
  const [selectedWithdrawal, setSelectedWithdrawal] = React.useState<Withdrawal | null>(null);
  const [confirmDialog, setConfirmDialog] = React.useState<{
    action: "APPROVE" | "REJECT";
    item: Withdrawal;
  } | null>(null);
  // Required decision reason (plan: approve/reject needs confirm + reason)
  const [reason, setReason] = React.useState("");

  const openConfirm = (action: "APPROVE" | "REJECT", item: Withdrawal) => {
    setReason("");
    setConfirmDialog({ action, item });
  };

  // Toast
  const [toastMessage, setToastMessage] = React.useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const filteredItems = React.useMemo(() => {
    return withdrawals.filter((w) => {
      const q = searchTerm.toLowerCase().trim();
      const matchesSearch =
        !q ||
        w.userName.toLowerCase().includes(q) ||
        w.userEmail.toLowerCase().includes(q) ||
        w.referenceId.toLowerCase().includes(q);

      const matchesStatus = statusFilter === "ALL" || w.status === statusFilter;
      const matchesType = typeFilter === "ALL" || w.payoutType === typeFilter;

      return matchesSearch && matchesStatus && matchesType;
    });
  }, [withdrawals, searchTerm, statusFilter, typeFilter]);

  const totalPages = Math.ceil(filteredItems.length / pageSize) || 1;
  const paginatedItems = filteredItems.slice(
    (page - 1) * pageSize,
    page * pageSize
  );

  const handleExecuteAction = () => {
    if (!confirmDialog || !reason.trim()) return;
    const { action, item } = confirmDialog;
    const notes = reason.trim();

    setWithdrawals((prev) =>
      prev.map((w) => {
        if (w.id !== item.id) return w;
        return {
          ...w,
          status: (action === "APPROVE" ? "APPROVED" : "REJECTED") as WithdrawalStatus,
          processedAt: new Date().toISOString(),
          notes,
        };
      })
    );

    if (selectedWithdrawal && selectedWithdrawal.id === item.id) {
      setSelectedWithdrawal((prev) =>
        prev
          ? {
              ...prev,
              status: (action === "APPROVE" ? "APPROVED" : "REJECTED") as WithdrawalStatus,
              processedAt: new Date().toISOString(),
              notes,
            }
          : null
      );
    }

    setConfirmDialog(null);
    setReason("");
    showToast(
      action === "APPROVE"
        ? `Withdrawal ${item.referenceId} approved successfully.`
        : `Withdrawal ${item.referenceId} has been rejected.`
    );
  };

  const riskFor = (userId: string) =>
    mockUsers.find((u) => u.id === userId);

  return (
    <div className="space-y-6">
      {/* Toast */}
      {toastMessage && (
        <div className="fixed bottom-5 right-5 z-50 flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-3 text-xs font-semibold text-white shadow-xl animate-in slide-in-from-bottom-5">
          <CheckCircle2 className="h-4 w-4 text-emerald-400" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">
              Withdrawal Requests
            </h1>
            <span className="rounded-full bg-amber-50 px-2.5 py-0.5 text-xs font-bold text-amber-700 border border-amber-200">
              {withdrawals.filter((w) => w.status === "PENDING").length} pending review
            </span>
          </div>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Review, approve, and execute disbursements for Bank Account and Paytm transfers.
          </p>
        </div>

        <Button variant="outline" size="sm" className="h-9 text-xs">
          <Download className="mr-2 h-4 w-4 text-slate-500" />
          Export Payout CSV
        </Button>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-white p-3 rounded-xl border border-slate-200 shadow-2xs">
        {/* Search Field */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Search by user, email, or reference ID..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setPage(1);
            }}
            className="pl-9 h-9 text-xs sm:text-sm border-slate-200"
          />
        </div>

        {/* Filter Dropdowns */}
        <div className="flex items-center gap-2">
          {/* Status Filter */}
          <Select
            value={statusFilter}
            onValueChange={(val) => {
              setStatusFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[140px] h-9 text-xs">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Statuses</SelectItem>
              <SelectItem value="PENDING">Pending</SelectItem>
              <SelectItem value="APPROVED">Approved</SelectItem>
              <SelectItem value="PROCESSED">Processed</SelectItem>
              <SelectItem value="REJECTED">Rejected</SelectItem>
            </SelectContent>
          </Select>

          {/* Type Filter */}
          <Select
            value={typeFilter}
            onValueChange={(val) => {
              setTypeFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[140px] h-9 text-xs">
              <SelectValue placeholder="Method" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Methods</SelectItem>
              <SelectItem value="BANK_ACCOUNT">Bank Account</SelectItem>
              <SelectItem value="PAYTM">Paytm</SelectItem>
            </SelectContent>
          </Select>

          {(searchTerm || statusFilter !== "ALL" || typeFilter !== "ALL") && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setSearchTerm("");
                setStatusFilter("ALL");
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

      {/* Withdrawals Table */}
      <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
        {paginatedItems.length === 0 ? (
          <EmptyState
            icon={CreditCard}
            title="No withdrawal requests found"
            description="There are currently no requests matching your search or filters."
          />
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="bg-slate-50/75">
                <TableHead className="font-semibold text-slate-600">Reference ID</TableHead>
                <TableHead className="font-semibold text-slate-600">User Account</TableHead>
                <TableHead className="font-semibold text-slate-600">Payout Method</TableHead>
                <TableHead className="font-semibold text-slate-600">Amount</TableHead>
                <TableHead className="font-semibold text-slate-600">Status</TableHead>
                <TableHead className="font-semibold text-slate-600">Requested Date</TableHead>
                <TableHead className="font-semibold text-slate-600 text-center w-[120px]">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {paginatedItems.map((w) => {
                const isPaytm = w.payoutType === "PAYTM";
                return (
                  <TableRow
                    key={w.id}
                    onClick={() => setSelectedWithdrawal(w)}
                    className="cursor-pointer hover:bg-slate-50/80 transition-colors"
                  >
                    <TableCell>
                      <span className="font-mono text-xs font-bold text-slate-800">
                        {w.referenceId}
                      </span>
                    </TableCell>

                    <TableCell>
                      <div>
                        <div className="font-semibold text-slate-900 leading-tight">
                          {w.userName}
                        </div>
                        <div className="text-[11px] text-slate-400">{w.userEmail}</div>
                      </div>
                    </TableCell>

                    <TableCell>
                      <div className="flex items-center gap-2">
                        <div
                          className={`flex h-7 w-7 items-center justify-center rounded-md ${
                            isPaytm ? "bg-neutral-100 text-neutral-700" : "bg-neutral-100 text-neutral-700"
                          }`}
                        >
                          {isPaytm ? <Wallet className="h-3.5 w-3.5" /> : <Building2 className="h-3.5 w-3.5" />}
                        </div>
                        <div>
                          <div className="text-xs font-semibold text-slate-800">
                            {isPaytm ? "Paytm Wallet" : (w.payoutDetails.bankName || "Bank Transfer")}
                          </div>
                          <div className="text-[10px] text-slate-400 font-mono">
                            {isPaytm
                              ? `•••• •••• ${w.payoutDetails.paytmNumber?.slice(-2)}`
                              : `•••• ${w.payoutDetails.accountNumber?.slice(-4)} · ${w.payoutDetails.ifscCode}`}
                          </div>
                        </div>
                      </div>
                    </TableCell>

                    <TableCell>
                      <span className="font-bold text-slate-900 text-sm">
                        {formatCurrency(w.amount)}
                      </span>
                    </TableCell>

                    <TableCell>
                      <StatusBadge status={w.status} />
                    </TableCell>

                    <TableCell>
                      <span className="text-xs text-slate-500">{formatDate(w.createdAt)}</span>
                    </TableCell>

                    <TableCell className="text-center" onClick={(e) => e.stopPropagation()}>
                      {w.status === "PENDING" ? (
                        <div className="flex items-center justify-center gap-1.5">
                          <Button
                            size="sm"
                            className="h-7 px-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-[11px] font-semibold"
                            onClick={() => openConfirm("APPROVE", w)}
                          >
                            <CheckCircle className="mr-1 h-3 w-3" /> Approve
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            className="h-7 px-2 text-red-600 hover:bg-red-50 text-[11px]"
                            onClick={() => openConfirm("REJECT", w)}
                          >
                            <XCircle className="h-3.5 w-3.5" />
                          </Button>
                        </div>
                      ) : (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setSelectedWithdrawal(w)}
                          className="h-7 px-2 text-xs text-slate-500 hover:text-slate-900"
                        >
                          View Details
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        )}
      </div>

      {/* Pagination Footer */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between px-2 pt-1">
          <p className="text-xs text-slate-500 font-medium">
            Showing {(page - 1) * pageSize + 1}–{Math.min(page * pageSize, filteredItems.length)} of{" "}
            {filteredItems.length} requests
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

      {/* WITHDRAWAL DETAIL MODAL */}
      {selectedWithdrawal && (
        <Dialog open={Boolean(selectedWithdrawal)} onOpenChange={(open) => !open && setSelectedWithdrawal(null)}>
          <DialogContent className="max-w-lg p-6">
            <DialogHeader className="pb-2 border-b border-slate-100">
              <div className="flex items-center justify-between">
                <div>
                  <DialogTitle className="text-base font-bold text-slate-900">
                    Withdrawal Request Details
                  </DialogTitle>
                  <DialogDescription className="text-xs font-mono text-slate-400 mt-0.5">
                    Ref ID: {selectedWithdrawal.referenceId}
                  </DialogDescription>
                </div>
                <StatusBadge status={selectedWithdrawal.status} />
              </div>
            </DialogHeader>

            <div className="space-y-4 pt-2">
              <div className="rounded-xl bg-slate-50 p-4 border border-slate-200/70 text-center">
                <div className="text-xs font-semibold text-slate-400 uppercase">Payout Amount</div>
                <div className="text-3xl font-extrabold text-slate-900 mt-1">
                  {formatCurrency(selectedWithdrawal.amount)}
                </div>
              </div>

              <div className="space-y-2 text-xs">
                <div className="flex justify-between py-1.5 border-b border-slate-100">
                  <span className="text-slate-400 font-medium">Recipient Name</span>
                  <span className="font-semibold text-slate-800">{selectedWithdrawal.userName}</span>
                </div>
                <div className="flex justify-between py-1.5 border-b border-slate-100">
                  <span className="text-slate-400 font-medium">User Email</span>
                  <span className="font-semibold text-slate-800">{selectedWithdrawal.userEmail}</span>
                </div>
                {(() => {
                  const risk = riskFor(selectedWithdrawal.userId);
                  if (!risk) return null;
                  return (
                    <>
                      <div className="flex justify-between items-center py-1.5 border-b border-slate-100">
                        <span className="text-slate-400 font-medium">Account Status</span>
                        <StatusBadge status={risk.accountStatus} />
                      </div>
                      <div className="flex justify-between items-center py-1.5 border-b border-slate-100">
                        <span className="text-slate-400 font-medium">Verification</span>
                        <StatusBadge status={risk.verificationStatus} />
                      </div>
                    </>
                  );
                })()}
                {selectedWithdrawal.notes && (
                  <div className="flex justify-between py-1.5 border-b border-slate-100">
                    <span className="text-slate-400 font-medium">Decision Note</span>
                    <span className="font-semibold text-slate-800 text-right max-w-[60%]">
                      {selectedWithdrawal.notes}
                    </span>
                  </div>
                )}
                <div className="flex justify-between py-1.5 border-b border-slate-100">
                  <span className="text-slate-400 font-medium">Payout Route</span>
                  <span className="font-semibold text-slate-800">
                    {selectedWithdrawal.payoutType === "PAYTM" ? "Paytm Mobile Wallet" : "Bank Transfer"}
                  </span>
                </div>
                {selectedWithdrawal.payoutType === "PAYTM" ? (
                  <div className="flex justify-between py-1.5 border-b border-slate-100">
                    <span className="text-slate-400 font-medium">Linked Paytm Mobile</span>
                    <span className="font-mono font-semibold text-slate-800">
                      +91 {selectedWithdrawal.payoutDetails.paytmNumber}
                    </span>
                  </div>
                ) : (
                  <>
                    <div className="flex justify-between py-1.5 border-b border-slate-100">
                      <span className="text-slate-400 font-medium">Bank Name</span>
                      <span className="font-semibold text-slate-800">
                        {selectedWithdrawal.payoutDetails.bankName}
                      </span>
                    </div>
                    <div className="flex justify-between py-1.5 border-b border-slate-100">
                      <span className="text-slate-400 font-medium">Account Number</span>
                      <span className="font-mono font-semibold text-slate-800">
                        {selectedWithdrawal.payoutDetails.accountNumber}
                      </span>
                    </div>
                    <div className="flex justify-between py-1.5 border-b border-slate-100">
                      <span className="text-slate-400 font-medium">IFSC Code</span>
                      <span className="font-mono font-semibold text-slate-800">
                        {selectedWithdrawal.payoutDetails.ifscCode}
                      </span>
                    </div>
                  </>
                )}
                <div className="flex justify-between py-1.5 border-b border-slate-100">
                  <span className="text-slate-400 font-medium">Submission Timestamp</span>
                  <span className="text-slate-600">{formatDate(selectedWithdrawal.createdAt)}</span>
                </div>
              </div>
            </div>

            <DialogFooter className="pt-4 border-t border-slate-100 gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setSelectedWithdrawal(null)}
                className="text-xs"
              >
                Close
              </Button>
              {selectedWithdrawal.status === "PENDING" && (
                <>
                  <Button
                    size="sm"
                    variant="outline"
                    className="text-red-600 border-red-200 hover:bg-red-50 text-xs"
                    onClick={() => {
                      openConfirm("REJECT", selectedWithdrawal);
                    }}
                  >
                    Reject
                  </Button>
                  <Button
                    size="sm"
                    className="bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-xs"
                    onClick={() => {
                      openConfirm("APPROVE", selectedWithdrawal);
                    }}
                  >
                    Approve Disbursement
                  </Button>
                </>
              )}
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}

      {/* CONFIRMATION DIALOG */}
      {confirmDialog && (
        <Dialog open={Boolean(confirmDialog)} onOpenChange={(open) => !open && setConfirmDialog(null)}>
          <DialogContent className="max-w-md p-6">
            <DialogHeader>
              <DialogTitle className="text-base font-bold text-slate-900">
                {confirmDialog.action === "APPROVE" ? "Approve Payout" : "Reject Withdrawal"}
              </DialogTitle>
              <DialogDescription className="text-xs text-slate-500 pt-1">
                {confirmDialog.action === "APPROVE"
                  ? `Execute disbursement of ${formatCurrency(confirmDialog.item.amount)} to ${confirmDialog.item.userName}?`
                  : `Reject withdrawal request ${confirmDialog.item.referenceId} and refund balance to user account?`}
              </DialogDescription>
            </DialogHeader>

            <div className="pt-3">
              <label
                htmlFor="decision-reason"
                className="text-xs font-semibold text-slate-700"
              >
                Decision reason (required)
              </label>
              <Textarea
                id="decision-reason"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder={
                  confirmDialog.action === "APPROVE"
                    ? "e.g. Verified payout method, balance sufficient"
                    : "e.g. Unverified account, duplicate request"
                }
                className="mt-1.5 text-xs"
                rows={3}
              />
            </div>

            <DialogFooter className="pt-4 gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setConfirmDialog(null)}
                className="text-xs"
              >
                Cancel
              </Button>
              <Button
                size="sm"
                onClick={handleExecuteAction}
                disabled={!reason.trim()}
                className={`text-xs ${
                  confirmDialog.action === "APPROVE"
                    ? "bg-emerald-600 hover:bg-emerald-700 text-white font-semibold"
                    : "bg-red-600 hover:bg-red-700 text-white font-semibold"
                }`}
              >
                Confirm {confirmDialog.action === "APPROVE" ? "Approval" : "Rejection"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
