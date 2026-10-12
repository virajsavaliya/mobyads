# MobyAds — DESIGN.md (canonical)

Brand: monochrome black & white — calm, premium, fintech; rewarding but not casino-like. No slot-machine effects around money. Reward moment: short subtle confirmation only after server credit. One primary action per screen.

## Brand colors (from `lib/core/theme/app_colors.dart`)

- Primary black ramp: `0xFF18181B` (zinc-900) / `0xFF000000` / tints `0xFFF4F4F5` / `0xFFE4E4E7`
- Accent: same monochrome ramp; coin marker gray `0xFF71717A`
- Neutrals: bg `0xFFFAFAFA`, surface/card `0xFFFFFFFF`, divider `0xFFE4E4E7`, border `0xFFD4D4D8`
- Text: primary `0xFF09090B`, secondary `0xFF52525B`, muted `0xFFA1A1AA`, inverse `0xFFFFFFFF`
- Exception: semantic status colors keep meaning (success `0xFF10B981`, warning `0xFFF59E0B`, error `0xFFEF4444`, info `0xFF3B82F6`) and are reserved for statuses only — never decoration. Dark ad slides use distinct zinc gradients so placements stay distinguishable without hue.

## Status vocabulary (fixed everywhere — same label, color, icon)

Ledger: PENDING (amber), AVAILABLE (emerald), WITHDRAWN (blue), REVERSED (slate), FAILED (red).
Withdrawals: PENDING (amber), APPROVED (emerald), PROCESSING (blue), PAID (emerald), REJECTED (red).

Flutter: `AppColors.success/warning/error/info` + StatusChip in wallet screen. Web (Tailwind): emerald-50/700, amber-50/700-800, blue-50/700-800, slate-100/600-700, red-50/700 — see `StatusBadge.tsx`.

Done: `StatusBadge.tsx` covers AVAILABLE, WITHDRAWN, REVERSED, PROCESSING, PAID, EXPIRED, DISABLED per this file.

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

- Polish (B&W): brand re-themed to monochrome zinc ramp; semantic status colors retained as the documented exception; ad slides use distinct zinc gradients.
