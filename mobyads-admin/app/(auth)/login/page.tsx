"use client";

import * as React from "react";
import { Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Lock, Shield, ArrowRight, AlertCircle } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { setAdminSession } from "@/lib/auth";

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const returnTo = searchParams.get("from") || "/dashboard";

  const [email, setEmail] = React.useState("admin@mobyads.internal");
  const [password, setPassword] = React.useState("admin12345");
  const [emailError, setEmailError] = React.useState<string | null>(null);
  const [passwordError, setPasswordError] = React.useState<string | null>(null);
  const [generalError, setGeneralError] = React.useState<string | null>(null);
  const [isLoading, setIsLoading] = React.useState(false);

  const validate = () => {
    let isValid = true;
    setEmailError(null);
    setPasswordError(null);
    setGeneralError(null);

    const trimmedEmail = email.trim();
    if (!trimmedEmail) {
      setEmailError("Administrator email is required");
      isValid = false;
    } else if (!/\S+@\S+\.\S+/.test(trimmedEmail)) {
      setEmailError("Please enter a valid email address");
      isValid = false;
    }

    if (!password) {
      setPasswordError("Password is required");
      isValid = false;
    } else if (password.length < 4) {
      setPasswordError("Password must be at least 4 characters");
      isValid = false;
    }

    return isValid;
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setIsLoading(true);

    // Mock Authentication: Any valid format email/password succeeds and creates a session
    setTimeout(() => {
      setAdminSession(email.trim());
      setIsLoading(false);
      router.push(returnTo);
      router.refresh();
    }, 400);
  };

  return (
    <Card className="border-slate-200 bg-white shadow-xs rounded-xl overflow-hidden">
      <CardHeader className="space-y-1 p-6 sm:p-7 pb-4">
        <CardTitle className="text-base font-bold text-slate-900">
          Sign In
        </CardTitle>
        <CardDescription className="text-xs text-slate-500">
          Enter your administrative credentials to continue
        </CardDescription>
      </CardHeader>

      <CardContent className="p-6 sm:p-7 pt-0">
        <form onSubmit={handleLogin} className="space-y-4" noValidate>
          {/* General Error Banner if needed */}
          {generalError && (
            <div className="flex items-center gap-2 p-2.5 rounded-lg bg-red-50 text-red-700 text-xs border border-red-200">
              <AlertCircle className="h-4 w-4 shrink-0" />
              <span>{generalError}</span>
            </div>
          )}

          {/* Email Field with stable error height */}
          <div className="space-y-1">
            <Label htmlFor="email" className="text-xs font-semibold text-slate-700">
              Administrator Email
            </Label>
            <Input
              id="email"
              type="email"
              placeholder="admin@mobyads.internal"
              autoComplete="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                if (emailError) setEmailError(null);
              }}
              className={`h-9 text-xs sm:text-sm border-slate-200 ${
                emailError ? "border-red-400 focus-visible:ring-red-500" : ""
              }`}
            />
            <div className="min-h-[16px] pt-0.5">
              {emailError && (
                <p className="text-[11px] font-medium text-red-600 leading-none">
                  {emailError}
                </p>
              )}
            </div>
          </div>

          {/* Password Field with stable error height */}
          <div className="space-y-1">
            <Label htmlFor="password" className="text-xs font-semibold text-slate-700">
              Password
            </Label>
            <Input
              id="password"
              type="password"
              placeholder="••••••••••••"
              autoComplete="current-password"
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                if (passwordError) setPasswordError(null);
              }}
              className={`h-9 text-xs sm:text-sm border-slate-200 ${
                passwordError ? "border-red-400 focus-visible:ring-red-500" : ""
              }`}
            />
            <div className="min-h-[16px] pt-0.5">
              {passwordError && (
                <p className="text-[11px] font-medium text-red-600 leading-none">
                  {passwordError}
                </p>
              )}
            </div>
          </div>

          {/* Submit Button */}
          <Button
            type="submit"
            className="w-full h-9 bg-blue-600 hover:bg-blue-700 font-semibold text-xs sm:text-sm text-white shadow-xs transition-colors"
            disabled={isLoading}
          >
            {isLoading ? (
              <span className="flex items-center gap-2">
                <span className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-white border-t-transparent" />
                Signing in...
              </span>
            ) : (
              <span className="flex items-center justify-center gap-1.5">
                <Lock className="h-3.5 w-3.5" />
                Login to Console
                <ArrowRight className="h-3.5 w-3.5 ml-1" />
              </span>
            )}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

export default function LoginPage() {
  return (
    <div className="flex min-h-screen w-full items-center justify-center bg-slate-100/70 p-4 sm:p-6 lg:p-8">
      <div className="w-full max-w-sm space-y-6 my-auto">
        {/* Utilitarian Admin Header */}
        <div className="flex flex-col items-center text-center space-y-1.5">
          <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-slate-900 text-white shadow-xs mb-1">
            <Shield className="h-5 w-5" />
          </div>
          <h1 className="text-xl font-bold tracking-tight text-slate-900 leading-tight">
            MobyAds Administration
          </h1>
          <p className="text-xs text-slate-500 max-w-xs">
            Internal console for platform operations and finance
          </p>
        </div>

        {/* Login Form with Suspense Boundary */}
        <Suspense
          fallback={
            <div className="h-72 rounded-xl border border-slate-200 bg-white p-6 animate-pulse" />
          }
        >
          <LoginForm />
        </Suspense>

        {/* Security Notice */}
        <div className="text-center text-[11px] text-slate-400 font-medium">
          Admin access is restricted and audit-logged.
        </div>
      </div>
    </div>
  );
}
