# MobyAds — DESIGN.md (canonical)

Brand: trustworthy, calm, modern-fintech; rewarding but not casino-like. No slot-machine effects around money. Reward moment: short subtle confirmation only after server credit. One primary action per screen.

## Brand colors (from `lib/core/theme/app_colors.dart`)

- Primary ocean teal: `0xFF0E7490` / dark `0xFF155E75` / light `0xFFE0F2FE` / container `0xFFBAE6FD`
- Accent money green: `0xFF10B981` / dark `0xFF059669` / light `0xFFD1FAE5`; coin gold `0xFFF59E0B`
- Neutrals: bg `0xFFF8FAFC`, surface/card `0xFFFFFFFF`, divider `0xFFE2E8F0`, border `0xFFCBD5E1`
- Text: primary `0xFF0F172A`, secondary `0xFF64748B`, muted `0xFF94A3B8`, inverse `0xFFFFFFFF`
- Semantic: success green `0xFF10B981`, warning amber `0xFFF59E0B`, error red `0xFFEF4444`, info blue `0xFF3B82F6`

## Status vocabulary (fixed everywhere — same label, color, icon)

Ledger: PENDING (amber), AVAILABLE (emerald), WITHDRAWN (blue), REVERSED (slate), FAILED (red).
Withdrawals: PENDING (amber), APPROVED (emerald), PROCESSING (blue), PAID (emerald), REJECTED (red).

Flutter: `AppColors.success/warning/error/info` + StatusChip in wallet screen. Web (Tailwind): emerald-50/700, amber-50/700-800, blue-50/700-800, slate-100/600-700, red-50/700 — see `StatusBadge.tsx`.

Gap (to fix): `StatusBadge.tsx` lacks AVAILABLE, WITHDRAWN, REVERSED, PROCESSING, PAID cases — they fall to neutral default. Add them to match this file.

## Type + spacing

- Headings Poppins (display 32/28/24 bold, headline 20, title 18/16/14); body Inter 16/14/12; money figures largest on screen with tabular numerals (`FontFeature.tabularFigures()`).
- Spacing 4/8/12/16/20/24/32/48; radii 4/8/12/16/24/full; button 52h, input 56h (`app_spacing.dart`).
- Server-driven copy: `Earn {reward}` filled from API. Sample figures labeled illustrative until rules freeze.

## Approved decisions log

- Home: balance hero (Available tabular + Pending secondary + Withdraw) above task; carousel demoted below money; daily-limit hint line; reward copy from `serverConfig` (`rewardMcq × mcqCount`).
- MCQ: single bottom banner (top strip removed); empty-questions error state with retry.
- Withdraw: fee/ETA behind `Fee & timing details` expander; double-submit guard; lifecycle stepper in success sheet (Requested → Approved → Processing → Paid; failure shows reason + funds-returned).
- Wallet: tabular money figures; info dialog minimum from server config (was hardcoded ₹10.00).
- Coupons: tabs Available/Used/Expired; code hidden until revealed; redeem + copy; terms collapsed.
- Legal: shared `LegalDocScreen` (banner + Contents TOC + anchor scroll); copy still placeholder pending review.
- A11y: 48px header targets, `Open profile` semantics label.
- Admin: dashboard 4 KPIs + needs-attention strip; withdrawals require decision reason + risk badges; users 6-column table; MCQ typed parser + skip-duplicates toggle; fraud page + live count (`lib/fraud.ts`); coupons page; audit log; settings env badge + TEST AdMob group; TEST badges wherever test IDs ship.
