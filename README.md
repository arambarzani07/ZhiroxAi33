# Zhirox AI Debt

**Zhirox AI Debt** is the official Kurdish Sorani RTL debt, credit, ledger, audit, and SaaS-ready money-protection system for markets and shops.

## Official product direction

This repository is the clean working home for the Zhirox AI Debt app + website codebase.

The system must support:

- Flutter mobile app
- Flutter web app
- Kurdish Sorani RTL UI
- PocketBase backend connection
- real database data only
- no fake production data
- customers, debts, payments, receipts, notifications
- immutable debt ledger
- audit logs
- approval center
- trust/risk score
- smart debt lock
- evidence vault
- QR/PDF receipts
- SaaS owner controls

## Build principle

One source codebase must serve both:

```text
Mobile App: Android / iOS
Web App: browser / Netlify / PWA
```

## Safety rule

Do not rewrite or delete working business logic without a safe migration. Add features module by module.
