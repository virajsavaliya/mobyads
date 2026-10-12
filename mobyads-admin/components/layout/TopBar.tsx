"use client";

import * as React from "react";
import { usePathname, useRouter } from "next/navigation";
import {
  Menu,
  ChevronDown,
  User,
  Settings,
  LogOut,
  ShieldAlert,
} from "lucide-react";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { clearAdminSession, getAdminSession } from "@/lib/auth";

const ROUTE_TITLES: Record<string, string> = {
  "/dashboard": "Dashboard Overview",
  "/users": "Users Management",
  "/mcq": "MCQ Question Bank",
  "/ads": "Ad Placements & SSV",
  "/withdrawals": "Withdrawal Requests",
  "/coupons": "Coupons",
  "/fraud": "Fraud & Risk",
  "/audit": "Roles & Audit Log",
  "/settings": "Platform Settings",
};

interface TopBarProps {
  onMenuClick?: () => void;
}

export function TopBar({ onMenuClick }: TopBarProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [adminEmail] = React.useState(() => {
    if (typeof document === "undefined") return "admin@mobyads.internal";
    return getAdminSession()?.email ?? "admin@mobyads.internal";
  });

  const pageTitle = ROUTE_TITLES[pathname] || "Dashboard";

  const handleLogout = () => {
    clearAdminSession();
    router.push("/login");
    router.refresh();
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 w-full items-center justify-between border-b border-slate-200 bg-white/95 px-4 sm:px-8 backdrop-blur-md">
      {/* Left: Mobile Toggle & Page Title */}
      <div className="flex items-center gap-3">
        <button
          onClick={onMenuClick}
          className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 lg:hidden cursor-pointer"
          title="Open menu"
        >
          <Menu className="h-5 w-5" />
        </button>

        <div>
          <h2 className="text-base sm:text-lg font-bold text-slate-900 leading-none">
            {pageTitle}
          </h2>
          <span className="text-[11px] text-slate-400 font-medium hidden sm:inline-block">
            MobyAds Administrative Control
          </span>
        </div>
      </div>

      {/* Right: Admin Profile Dropdown */}
      <div className="flex items-center gap-3">
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button className="flex items-center gap-2.5 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 hover:bg-slate-50 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-1 cursor-pointer">
              <Avatar className="h-7 w-7 bg-blue-600">
                <AvatarFallback className="bg-blue-600 text-[11px] font-bold text-white">
                  AD
                </AvatarFallback>
              </Avatar>
              <div className="hidden flex-col text-left sm:flex">
                <span className="text-xs font-semibold text-slate-900 leading-tight">
                  Super Admin
                </span>
                <span className="text-[10px] text-slate-400 font-mono">
                  {adminEmail}
                </span>
              </div>
              <ChevronDown className="h-3.5 w-3.5 text-slate-400" />
            </button>
          </DropdownMenuTrigger>

          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel className="font-normal">
              <div className="flex flex-col space-y-1">
                <p className="text-xs font-bold leading-none text-slate-900">
                  Super Admin
                </p>
                <p className="text-[11px] leading-none text-slate-500 font-mono">
                  {adminEmail}
                </p>
                <div className="mt-1 flex items-center gap-1 text-[10px] text-emerald-600 font-medium">
                  <ShieldAlert className="h-3 w-3" />
                  Full Privileges
                </div>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              className="cursor-pointer text-xs"
              onClick={() => router.push("/settings")}
            >
              <User className="mr-2 h-4 w-4 text-slate-400" />
              <span>Admin Profile</span>
            </DropdownMenuItem>
            <DropdownMenuItem
              className="cursor-pointer text-xs"
              onClick={() => router.push("/settings")}
            >
              <Settings className="mr-2 h-4 w-4 text-slate-400" />
              <span>System Settings</span>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={handleLogout}
              className="cursor-pointer text-xs text-red-600 focus:bg-red-50 focus:text-red-700"
            >
              <LogOut className="mr-2 h-4 w-4" />
              <span>Logout</span>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
