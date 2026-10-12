// Typed backend client for M2-M3 contract (PDF §2: backend is authority).
// Uses NEXT_PUBLIC_API_BASE_URL; falls back to dev URL from Flutter EnvConfig.

const BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL ??
  "https://api-dev.mobyads.com/api/v1";

async function req<T>(
  path: string,
  init: RequestInit & { adminToken?: string } = {},
): Promise<T> {
  const { adminToken, ...rest } = init;
  const res = await fetch(`${BASE}${path}`, {
    ...rest,
    headers: {
      "Content-Type": "application/json",
      ...(adminToken ? { Authorization: `Bearer ${adminToken}` } : {}),
      ...(rest.headers ?? {}),
    },
    cache: "no-store",
  });
  if (!res.ok) {
    throw new Error(`API ${path} failed: ${res.status}`);
  }
  return (await res.json()) as T;
}

export const api = {
  getPublicConfig: (t?: string) =>
    req<{ minWithdrawal: number; taskCooldownMinutes: number }>(
      "/config/public",
      { adminToken: t },
    ),
  listAdminUsers: (t: string) => req("/admin/users", { adminToken: t }),
  listAdminQuestions: (t: string) => req("/admin/questions", { adminToken: t }),
};
