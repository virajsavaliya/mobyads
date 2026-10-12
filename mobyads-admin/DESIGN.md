# MobyAds Admin — DESIGN.md (layout/density override)

Inherits root `mobyad/DESIGN.md` verbatim for brand colors, status vocabulary, type rules. This file overrides layout + density only.

- Shell: left sidebar + top bar + content; shared table/filter/drawer (`components/shared/`, `components/ui/`).
- Density: compact tables, filter chips, row expand for IDs (ledger audit); review card pattern for withdrawals (amount, user status, risk; history in expander).
- StatusBadge: covers AVAILABLE / WITHDRAWN / REVERSED / PROCESSING / PAID / EXPIRED / DISABLED per root mapping.
- Monochrome: brand blues/purples/indigo/sky remapped to neutral/black; emerald/amber/red kept for statuses only (same exception as app).
