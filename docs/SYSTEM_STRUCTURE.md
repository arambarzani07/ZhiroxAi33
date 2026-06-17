# Official System Structure — Zhirox AI Debt

## 1. Platform architecture

```text
Zhirox AI Debt
│
├── Flutter App + Web
│   ├── Android app
│   ├── iOS app
│   └── Flutter web / PWA
│
├── PocketBase Backend
│   ├── Auth
│   ├── Collections
│   ├── Storage
│   └── Access rules
│
├── Financial Core
│   ├── Customers
│   ├── Debts
│   ├── Payments
│   ├── Immutable ledger
│   ├── Receipts
│   └── PDF/QR verification
│
├── Safety and Control
│   ├── Audit logs
│   ├── Approval center
│   ├── Smart debt lock
│   ├── Trust score
│   ├── Risk level
│   └── Evidence vault
│
└── SaaS Layer
    ├── System owner
    ├── Markets
    ├── Licenses
    ├── Subscription plans
    ├── Support tickets
    └── Feature flags
```

## 2. Flutter folder structure

```text
lib/
  main.dart
  app/
  core/
    responsive/
    widgets/
    permissions/
    tenancy/
    utils/
  services/
  providers/
  screens/
    auth/
    owner/
    admin/
    employee/
    customer/
    shared/
  data/
    models/
    repositories/
```

## 3. Required PocketBase collections

```text
users
debts
payments
notifications
markets
audit_logs
debt_ledger_entries
approvals
receipts
customer_scores
smart_locks
evidence_files
dispute_cases
subscription_plans
licenses
support_tickets
```

## 4. App + web rule

The same Flutter codebase must adapt to screen size:

```text
mobile: bottom navigation + single column
tablet: compact navigation + two columns
desktop/web: RTL sidebar + dashboard grid + tables
```

## 5. Financial safety rule

Every debt and payment action must create:

```text
1. main record
2. ledger entry
3. audit log
4. receipt when applicable
5. notification when applicable
```
