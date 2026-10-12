"use client";

import * as React from "react";
import {
  Users,
  Search,
  ShieldCheck,
  ShieldAlert,
  ShieldBan,
  Wallet,
  Building2,
  ArrowUpRight,
  ArrowDownLeft,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  MoreVertical,
  X,
  ExternalLink,
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { EmptyState } from "@/components/shared/EmptyState";
import { mockUsers } from "@/lib/mock-data";
import { User, AccountStatus, VerificationStatus } from "@/lib/types";
import { formatCurrency, formatDate } from "@/lib/utils";

export default function UsersPage() {
  const [usersList, setUsersList] = React.useState<User[]>(mockUsers);
  const [searchTerm, setSearchTerm] = React.useState("");
  const [statusFilter, setStatusFilter] = React.useState<string>("ALL");
  const [verificationFilter, setVerificationFilter] = React.useState<string>("ALL");
  const [page, setPage] = React.useState(1);
  const pageSize = 8;

  // Selected User Detail Modal State
  const [selectedUser, setSelectedUser] = React.useState<User | null>(null);

  // Confirmation Dialog State
  const [confirmAction, setConfirmAction] = React.useState<{
    type: "MARK_REVIEW" | "BLOCK" | "UNBLOCK" | "VERIFY" | "REVOKE_VERIFY";
    user: User;
    title: string;
    description: string;
  } | null>(null);

  // Filter logic
  const filteredUsers = React.useMemo(() => {
    return usersList.filter((user) => {
      // Search match
      const query = searchTerm.toLowerCase().trim();
      const matchesSearch =
        !query ||
        user.name.toLowerCase().includes(query) ||
        user.email.toLowerCase().includes(query) ||
        user.phone.includes(query);

      // Status filter
      const matchesStatus =
        statusFilter === "ALL" || user.accountStatus === statusFilter;

      // Verification filter
      const matchesVerification =
        verificationFilter === "ALL" ||
        user.verificationStatus === verificationFilter;

      return matchesSearch && matchesStatus && matchesVerification;
    });
  }, [usersList, searchTerm, statusFilter, verificationFilter]);

  // Pagination logic
  const totalPages = Math.ceil(filteredUsers.length / pageSize) || 1;
  const paginatedUsers = filteredUsers.slice(
    (page - 1) * pageSize,
    page * pageSize
  );

  // Apply administrative action
  const executeAdminAction = () => {
    if (!confirmAction) return;
    const { type, user } = confirmAction;

    setUsersList((prev) =>
      prev.map((u) => {
        if (u.id !== user.id) return u;

        switch (type) {
          case "MARK_REVIEW":
            return { ...u, accountStatus: "REVIEW" as AccountStatus };
          case "BLOCK":
            return { ...u, accountStatus: "BLOCKED" as AccountStatus };
          case "UNBLOCK":
            return { ...u, accountStatus: "NORMAL" as AccountStatus };
          case "VERIFY":
            return { ...u, verificationStatus: "VERIFIED" as VerificationStatus };
          case "REVOKE_VERIFY":
            return { ...u, verificationStatus: "UNVERIFIED" as VerificationStatus };
          default:
            return u;
        }
      })
    );

    // Update active modal selectedUser if open
    if (selectedUser && selectedUser.id === user.id) {
      setSelectedUser((prev) => {
        if (!prev) return null;
        switch (type) {
          case "MARK_REVIEW":
            return { ...prev, accountStatus: "REVIEW" as AccountStatus };
          case "BLOCK":
            return { ...prev, accountStatus: "BLOCKED" as AccountStatus };
          case "UNBLOCK":
            return { ...prev, accountStatus: "NORMAL" as AccountStatus };
          case "VERIFY":
            return { ...prev, verificationStatus: "VERIFIED" as VerificationStatus };
          case "REVOKE_VERIFY":
            return { ...prev, verificationStatus: "UNVERIFIED" as VerificationStatus };
          default:
            return prev;
        }
      });
    }

    setConfirmAction(null);
  };

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .substring(0, 2)
      .toUpperCase();
  };

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">
              User Accounts
            </h1>
            <span className="rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-semibold text-slate-600">
              {usersList.length} total
            </span>
          </div>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Manage participants, verify identities, monitor balances, and review suspicious activity.
          </p>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-white p-3 rounded-xl border border-slate-200 shadow-2xs">
        {/* Search Field */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Search by name, email, or phone..."
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
              <SelectItem value="NORMAL">Normal</SelectItem>
              <SelectItem value="REVIEW">Under Review</SelectItem>
              <SelectItem value="BLOCKED">Blocked</SelectItem>
            </SelectContent>
          </Select>

          {/* Verification Filter */}
          <Select
            value={verificationFilter}
            onValueChange={(val) => {
              setVerificationFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[140px] h-9 text-xs">
              <SelectValue placeholder="Verification" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Verifications</SelectItem>
              <SelectItem value="VERIFIED">Verified</SelectItem>
              <SelectItem value="UNVERIFIED">Unverified</SelectItem>
            </SelectContent>
          </Select>

          {(searchTerm || statusFilter !== "ALL" || verificationFilter !== "ALL") && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setSearchTerm("");
                setStatusFilter("ALL");
                setVerificationFilter("ALL");
                setPage(1);
              }}
              className="h-9 px-2 text-xs text-slate-500 hover:text-slate-900"
            >
              Reset
            </Button>
          )}
        </div>
      </div>

      {/* Users Data Table */}
      <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
        {paginatedUsers.length === 0 ? (
          <EmptyState
            icon={Users}
            title="No matching users found"
            description="Try modifying your search keywords or filter criteria."
          />
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="bg-slate-50/75">
                <TableHead className="font-semibold text-slate-600">User</TableHead>
                <TableHead className="font-semibold text-slate-600">Contact</TableHead>
                <TableHead className="font-semibold text-slate-600">Account Status</TableHead>
                <TableHead className="font-semibold text-slate-600">Verification</TableHead>
                <TableHead className="font-semibold text-slate-600 text-right">Total Earned</TableHead>
                <TableHead className="font-semibold text-slate-600 text-center w-[80px]">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {paginatedUsers.map((user) => (
                <TableRow
                  key={user.id}
                  onClick={() => setSelectedUser(user)}
                  className="cursor-pointer hover:bg-slate-50/80 transition-colors"
                >
                  {/* Name + Avatar */}
                  <TableCell>
                    <div className="flex items-center gap-3">
                      <Avatar className="h-8 w-8 bg-neutral-200 text-black font-bold text-xs border border-neutral-300">
                        <AvatarFallback>{getInitials(user.name)}</AvatarFallback>
                      </Avatar>
                      <div>
                        <div className="font-semibold text-slate-900 leading-tight">
                          {user.name}
                        </div>
                        <div className="text-[11px] text-slate-400 font-mono">
                          {user.id}
                        </div>
                      </div>
                    </div>
                  </TableCell>

                  {/* Email & Phone */}
                  <TableCell>
                    <div className="space-y-0.5">
                      <div className="text-xs text-slate-700">{user.email}</div>
                      <div className="text-[11px] text-slate-400 font-mono">{user.phone}</div>
                    </div>
                  </TableCell>

                  {/* Status Badge */}
                  <TableCell>
                    <StatusBadge status={user.accountStatus} />
                  </TableCell>

                  {/* Verification Badge */}
                  <TableCell>
                    <StatusBadge status={user.verificationStatus} />
                  </TableCell>

                  {/* Total Earned */}
                  <TableCell className="text-right">
                    <span className="font-bold text-slate-900 text-sm">
                      {formatCurrency(user.totalEarned)}
                    </span>
                    <div className="text-[10px] text-slate-400">
                      {user.completedTasksCount} tasks
                    </div>
                  </TableCell>

                  {/* Row Actions Menu */}
                  <TableCell className="text-center" onClick={(e) => e.stopPropagation()}>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon" className="h-8 w-8 text-slate-400 hover:text-slate-800">
                          <MoreVertical className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end" className="w-48">
                        <DropdownMenuLabel className="text-xs">User Actions</DropdownMenuLabel>
                        <DropdownMenuItem onClick={() => setSelectedUser(user)} className="cursor-pointer text-xs">
                          <ExternalLink className="mr-2 h-3.5 w-3.5" /> View Details
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />

                        {user.accountStatus !== "REVIEW" && (
                          <DropdownMenuItem
                            onClick={() =>
                              setConfirmAction({
                                type: "MARK_REVIEW",
                                user,
                                title: "Mark Account for Review",
                                description: `Are you sure you want to flag ${user.name}'s account for administrative review?`,
                              })
                            }
                            className="cursor-pointer text-xs text-amber-700 focus:bg-amber-50"
                          >
                            <ShieldAlert className="mr-2 h-3.5 w-3.5 text-amber-600" />
                            Mark for Review
                          </DropdownMenuItem>
                        )}

                        {user.accountStatus === "BLOCKED" ? (
                          <DropdownMenuItem
                            onClick={() =>
                              setConfirmAction({
                                type: "UNBLOCK",
                                user,
                                title: "Unblock User Account",
                                description: `Restore normal login and quiz task access for ${user.name}?`,
                              })
                            }
                            className="cursor-pointer text-xs text-emerald-700 focus:bg-emerald-50"
                          >
                            <CheckCircle2 className="mr-2 h-3.5 w-3.5 text-emerald-600" />
                            Unblock Account
                          </DropdownMenuItem>
                        ) : (
                          <DropdownMenuItem
                            onClick={() =>
                              setConfirmAction({
                                type: "BLOCK",
                                user,
                                title: "Block User Account",
                                description: `Block ${user.name} from participating in tasks or withdrawing funds?`,
                              })
                            }
                            className="cursor-pointer text-xs text-red-600 focus:bg-red-50"
                          >
                            <ShieldBan className="mr-2 h-3.5 w-3.5 text-red-600" />
                            Block Account
                          </DropdownMenuItem>
                        )}

                        <DropdownMenuSeparator />

                        {user.verificationStatus === "VERIFIED" ? (
                          <DropdownMenuItem
                            onClick={() =>
                              setConfirmAction({
                                type: "REVOKE_VERIFY",
                                user,
                                title: "Revoke Verification",
                                description: `Revoke verified identity badge for ${user.name}?`,
                              })
                            }
                            className="cursor-pointer text-xs text-slate-600"
                          >
                            <X className="mr-2 h-3.5 w-3.5 text-slate-400" />
                            Revoke Verification
                          </DropdownMenuItem>
                        ) : (
                          <DropdownMenuItem
                            onClick={() =>
                              setConfirmAction({
                                type: "VERIFY",
                                user,
                                title: "Verify User Account",
                                description: `Mark ${user.name} as a verified identity?`,
                              })
                            }
                            className="cursor-pointer text-xs text-black focus:bg-neutral-100"
                          >
                            <ShieldCheck className="mr-2 h-3.5 w-3.5 text-neutral-900" />
                            Verify Account
                          </DropdownMenuItem>
                        )}
                      </DropdownMenuContent>
                    </DropdownMenu>
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
            Showing {(page - 1) * pageSize + 1}–{Math.min(page * pageSize, filteredUsers.length)} of{" "}
            {filteredUsers.length} users
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

      {/* USER DETAIL MODAL DIALOG */}
      {selectedUser && (
        <Dialog open={Boolean(selectedUser)} onOpenChange={(open) => !open && setSelectedUser(null)}>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto p-6">
            <DialogHeader className="space-y-3 pb-2 border-b border-slate-100">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Avatar className="h-12 w-12 bg-neutral-900 text-white font-bold text-base">
                    <AvatarFallback>{getInitials(selectedUser.name)}</AvatarFallback>
                  </Avatar>
                  <div>
                    <div className="flex items-center gap-2">
                      <DialogTitle className="text-lg font-bold text-slate-900">
                        {selectedUser.name}
                      </DialogTitle>
                      <StatusBadge status={selectedUser.accountStatus} />
                      <StatusBadge status={selectedUser.verificationStatus} />
                    </div>
                    <p className="text-xs text-slate-400 font-mono mt-0.5">
                      User ID: {selectedUser.id} · Joined {formatDate(selectedUser.createdAt)}
                    </p>
                  </div>
                </div>
              </div>
            </DialogHeader>

            {/* Quick Balances Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-2">
              <div className="rounded-lg bg-slate-50 p-3 border border-slate-100">
                <div className="text-[11px] font-semibold text-slate-400 uppercase">Available</div>
                <div className="text-base font-bold text-slate-900 mt-0.5">
                  {formatCurrency(selectedUser.balance)}
                </div>
              </div>
              <div className="rounded-lg bg-slate-50 p-3 border border-slate-100">
                <div className="text-[11px] font-semibold text-slate-400 uppercase">Pending</div>
                <div className="text-base font-bold text-amber-700 mt-0.5">
                  {formatCurrency(selectedUser.pendingBalance)}
                </div>
              </div>
              <div className="rounded-lg bg-slate-50 p-3 border border-slate-100">
                <div className="text-[11px] font-semibold text-slate-400 uppercase">Total Earned</div>
                <div className="text-base font-bold text-emerald-700 mt-0.5">
                  {formatCurrency(selectedUser.totalEarned)}
                </div>
              </div>
              <div className="rounded-lg bg-slate-50 p-3 border border-slate-100">
                <div className="text-[11px] font-semibold text-slate-400 uppercase">Withdrawn</div>
                <div className="text-base font-bold text-neutral-800 mt-0.5">
                  {formatCurrency(selectedUser.totalWithdrawn)}
                </div>
              </div>
            </div>

            {/* Detail Tabs */}
            <Tabs defaultValue="profile" className="pt-2">
              <TabsList className="grid w-full grid-cols-3 h-9">
                <TabsTrigger value="profile" className="text-xs">Profile Info</TabsTrigger>
                <TabsTrigger value="payouts" className="text-xs">
                  Payout Methods ({selectedUser.payoutMethods.length})
                </TabsTrigger>
                <TabsTrigger value="history" className="text-xs">
                  Wallet Transactions ({selectedUser.transactions.length})
                </TabsTrigger>
              </TabsList>

              {/* Tab 1: Profile Info */}
              <TabsContent value="profile" className="space-y-4 pt-3">
                <div className="rounded-lg border border-slate-100 bg-slate-50/50 p-4 space-y-3">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                    <div>
                      <span className="text-slate-400 font-medium block">Email Address</span>
                      <span className="font-semibold text-slate-800">{selectedUser.email}</span>
                    </div>
                    <div>
                      <span className="text-slate-400 font-medium block">Phone Number</span>
                      <span className="font-semibold text-slate-800">{selectedUser.phone}</span>
                    </div>
                    <div>
                      <span className="text-slate-400 font-medium block">Completed Quiz Tasks</span>
                      <span className="font-semibold text-slate-800">{selectedUser.completedTasksCount} tasks</span>
                    </div>
                    <div>
                      <span className="text-slate-400 font-medium block">Last Active</span>
                      <span className="font-semibold text-slate-800">{formatDate(selectedUser.lastActiveAt)}</span>
                    </div>
                  </div>
                </div>
              </TabsContent>

              {/* Tab 2: Payout Methods */}
              <TabsContent value="payouts" className="space-y-3 pt-3">
                {selectedUser.payoutMethods.length === 0 ? (
                  <div className="rounded-lg border border-dashed border-slate-200 p-6 text-center text-xs text-slate-500">
                    No saved payout methods on this account.
                  </div>
                ) : (
                  <div className="space-y-2">
                    {selectedUser.payoutMethods.map((pm) => {
                      const isPaytm = pm.type === "PAYTM";
                      return (
                        <div
                          key={pm.id}
                          className="flex items-center justify-between p-3.5 rounded-lg border border-slate-200 bg-white shadow-2xs"
                        >
                          <div className="flex items-center gap-3">
                            <div
                              className={`flex h-9 w-9 items-center justify-center rounded-lg ${
                                isPaytm ? "bg-neutral-100 text-neutral-700" : "bg-neutral-100 text-neutral-700"
                              }`}
                            >
                              {isPaytm ? <Wallet className="h-4 w-4" /> : <Building2 className="h-4 w-4" />}
                            </div>
                            <div>
                              <div className="flex items-center gap-2">
                                <span className="text-sm font-bold text-slate-900">
                                  {isPaytm ? "Paytm Wallet" : (pm.bankName || "Bank Transfer")}
                                </span>
                                {pm.isDefault && (
                                  <span className="rounded bg-slate-100 px-1.5 py-0.5 text-[9px] font-bold text-slate-600">
                                    DEFAULT
                                  </span>
                                )}
                              </div>
                              <div className="text-xs text-slate-500 font-mono mt-0.5">
                                {isPaytm
                                  ? `Linked Phone: •••• •••• ${pm.paytmNumber?.slice(-2)}`
                                  : `•••• ${pm.accountNumber?.slice(-4)} · IFSC: ${pm.ifscCode}`}
                              </div>
                            </div>
                          </div>
                          <span className="text-xs text-slate-400 font-medium">
                            Holder: {pm.holderName}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                )}
              </TabsContent>

              {/* Tab 3: Wallet Transactions */}
              <TabsContent value="history" className="space-y-2 pt-3 max-h-64 overflow-y-auto">
                {selectedUser.transactions.length === 0 ? (
                  <div className="rounded-lg border border-dashed border-slate-200 p-6 text-center text-xs text-slate-500">
                    No transactions recorded for this user.
                  </div>
                ) : (
                  <div className="divide-y divide-slate-100 border border-slate-100 rounded-lg overflow-hidden bg-white">
                    {selectedUser.transactions.map((tx) => (
                      <div key={tx.id} className="flex items-center justify-between p-3">
                        <div className="flex items-center gap-2.5">
                          <div
                            className={`flex h-7 w-7 items-center justify-center rounded-full ${
                              tx.isCredit ? "bg-emerald-50 text-emerald-600" : "bg-neutral-100 text-neutral-700"
                            }`}
                          >
                            {tx.isCredit ? <ArrowDownLeft className="h-3.5 w-3.5" /> : <ArrowUpRight className="h-3.5 w-3.5" />}
                          </div>
                          <div>
                            <p className="text-xs font-semibold text-slate-900 leading-tight">{tx.title}</p>
                            <p className="text-[10px] text-slate-400 font-mono mt-0.5">
                              {formatDate(tx.timestamp)} · {tx.category || "TRANSACTION"}
                            </p>
                          </div>
                        </div>
                        <div className="text-right">
                          <span className={`text-xs font-bold ${tx.isCredit ? "text-emerald-700" : "text-slate-900"}`}>
                            {tx.isCredit ? "+" : "-"}{formatCurrency(tx.amount)}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </TabsContent>
            </Tabs>

            {/* Admin Action Buttons on Modal */}
            <div className="border-t border-slate-100 pt-4 flex flex-wrap items-center justify-between gap-2">
              <div className="flex items-center gap-2">
                {selectedUser.accountStatus !== "REVIEW" && (
                  <Button
                    size="sm"
                    variant="outline"
                    className="text-amber-700 border-amber-200 hover:bg-amber-50 text-xs h-8"
                    onClick={() =>
                      setConfirmAction({
                        type: "MARK_REVIEW",
                        user: selectedUser,
                        title: "Mark for Review",
                        description: `Flag ${selectedUser.name} for manual compliance inspection?`,
                      })
                    }
                  >
                    <ShieldAlert className="mr-1.5 h-3.5 w-3.5 text-amber-600" />
                    Mark for Review
                  </Button>
                )}

                {selectedUser.accountStatus === "BLOCKED" ? (
                  <Button
                    size="sm"
                    variant="outline"
                    className="text-emerald-700 border-emerald-200 hover:bg-emerald-50 text-xs h-8"
                    onClick={() =>
                      setConfirmAction({
                        type: "UNBLOCK",
                        user: selectedUser,
                        title: "Unblock Account",
                        description: `Lift block and restore task access for ${selectedUser.name}?`,
                      })
                    }
                  >
                    <CheckCircle2 className="mr-1.5 h-3.5 w-3.5 text-emerald-600" />
                    Unblock User
                  </Button>
                ) : (
                  <Button
                    size="sm"
                    variant="outline"
                    className="text-red-600 border-red-200 hover:bg-red-50 text-xs h-8"
                    onClick={() =>
                      setConfirmAction({
                        type: "BLOCK",
                        user: selectedUser,
                        title: "Block User Account",
                        description: `Block ${selectedUser.name}? They will be immediately prevented from starting tasks or withdrawing.`,
                      })
                    }
                  >
                    <ShieldBan className="mr-1.5 h-3.5 w-3.5 text-red-600" />
                    Block Account
                  </Button>
                )}
              </div>

              <div>
                {selectedUser.verificationStatus === "VERIFIED" ? (
                  <Button
                    size="sm"
                    variant="ghost"
                    className="text-slate-500 hover:text-slate-900 text-xs h-8"
                    onClick={() =>
                      setConfirmAction({
                        type: "REVOKE_VERIFY",
                        user: selectedUser,
                        title: "Revoke Verification",
                        description: `Remove verification badge from ${selectedUser.name}?`,
                      })
                    }
                  >
                    Revoke Verification
                  </Button>
                ) : (
                  <Button
                    size="sm"
                    className="bg-neutral-900 hover:bg-black text-white text-xs h-8"
                    onClick={() =>
                      setConfirmAction({
                        type: "VERIFY",
                        user: selectedUser,
                        title: "Verify Account",
                        description: `Grant verified status badge to ${selectedUser.name}?`,
                      })
                    }
                  >
                    <ShieldCheck className="mr-1.5 h-3.5 w-3.5" />
                    Verify Account
                  </Button>
                )}
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}

      {/* CONFIRMATION ACTION DIALOG */}
      {confirmAction && (
        <Dialog open={Boolean(confirmAction)} onOpenChange={(open) => !open && setConfirmAction(null)}>
          <DialogContent className="max-w-md p-6">
            <DialogHeader>
              <DialogTitle className="text-base font-bold text-slate-900">
                {confirmAction.title}
              </DialogTitle>
              <DialogDescription className="text-xs text-slate-500 pt-1">
                {confirmAction.description}
              </DialogDescription>
            </DialogHeader>

            <DialogFooter className="pt-4 gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setConfirmAction(null)}
                className="text-xs"
              >
                Cancel
              </Button>
              <Button
                size="sm"
                onClick={executeAdminAction}
                className={`text-xs ${
                  confirmAction.type === "BLOCK"
                    ? "bg-red-600 hover:bg-red-700 text-white"
                    : confirmAction.type === "MARK_REVIEW"
                    ? "bg-amber-600 hover:bg-amber-700 text-white"
                    : "bg-neutral-900 hover:bg-black text-white"
                }`}
              >
                Confirm Action
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
