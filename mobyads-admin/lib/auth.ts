export const ADMIN_SESSION_COOKIE = "mobyads_admin_session";

export interface AdminSession {
  email: string;
  name: string;
  role: string;
  token: string;
  loginTime: string;
}

export function setAdminSession(email: string): AdminSession {
  const session: AdminSession = {
    email: email || "admin@mobyads.internal",
    name: "Super Admin",
    role: "ADMIN",
    token: `fake_jwt_admin_${Date.now()}`,
    loginTime: new Date().toISOString(),
  };

  // Set Cookie for server-side Next.js middleware protection
  if (typeof document !== "undefined") {
    document.cookie = `${ADMIN_SESSION_COOKIE}=${encodeURIComponent(
      JSON.stringify(session)
    )}; path=/; max-age=86400; SameSite=Lax`;
    localStorage.setItem(ADMIN_SESSION_COOKIE, JSON.stringify(session));
  }

  return session;
}

export function getAdminSession(): AdminSession | null {
  if (typeof window === "undefined") return null;

  try {
    const raw = localStorage.getItem(ADMIN_SESSION_COOKIE);
    if (raw) return JSON.parse(raw);

    // Fallback: check document.cookie
    const match = document.cookie
      .split("; ")
      .find((row) => row.startsWith(`${ADMIN_SESSION_COOKIE}=`));
    if (match) {
      return JSON.parse(decodeURIComponent(match.split("=")[1]));
    }
  } catch {
    return null;
  }
  return null;
}

export function clearAdminSession(): void {
  if (typeof document !== "undefined") {
    document.cookie = `${ADMIN_SESSION_COOKIE}=; path=/; max-age=0; SameSite=Lax`;
    localStorage.removeItem(ADMIN_SESSION_COOKIE);
  }
}
