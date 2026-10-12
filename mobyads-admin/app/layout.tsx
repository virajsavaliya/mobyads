import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "MobyAds Admin Portal",
  description: "Management Console for MobyAds quiz app, SSV rewards, and payouts.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-slate-50 text-slate-900 antialiased">
        {children}
      </body>
    </html>
  );
}
