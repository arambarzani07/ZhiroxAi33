# Frontend Completion Checklist — Zhirox AI Debt

This checklist defines what must be complete before database setup and production QA.

## Current frontend status

```text
Flutter analyze: passing in CI
Flutter web release build: passing in CI
Main dashboard: implemented
Role-based action visibility: implemented
Owner panel: implemented
Schema health screen: implemented
Customer list/profile: implemented
Add debt form: implemented
Receive payment form: implemented
Approval center: implemented
Audit log: implemented
Receipt history + QR UI: implemented
Evidence Vault: implemented
Smart Lock UI: implemented
Risk/Trust panel: implemented
```

## Frontend guard layer

```text
Dashboard uses guarded Add Debt screen.
Dashboard uses guarded Receive Payment screen.
Dashboard uses guarded Customer List screen.
Dashboard uses guarded Approval Center screen.
Dashboard uses guarded Audit Log screen.
Owner Panel has direct guard.
Schema Health has direct guard.
```

## Frontend still expected before final visual lock

```text
1. Add customer create/edit frontend screen.
2. Add market settings/profile frontend screen.
3. Add customer portal read-only frontend screen.
4. Add manager reports placeholder/foundation screen.
5. Add notification center frontend screen.
6. Add export/print UI entry points.
7. Polish Kurdish copy and empty states.
8. Polish mobile spacing and tablet/web responsive cards.
```

## Database-dependent items

These should not block frontend work, but must be connected after PocketBase setup:

```text
PocketBase collections and fields
PocketBase API rules
First system_owner user
First market
First market_manager user
First employee user
First customer records
Seed records for QA only
```

## Do not add fake production data

The frontend can show empty states and setup instructions. Do not hardcode fake financial customer/debt/payment records into production paths.
