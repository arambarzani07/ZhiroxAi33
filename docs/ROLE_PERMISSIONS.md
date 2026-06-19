# Role Permission Matrix — Zhirox AI Debt

This document defines the first production permission baseline.

## Roles

```text
system_owner
market_manager
employee
customer
```

## Rules

### system_owner

Allowed:

```text
Owner Panel
Schema Health
Markets overview
Licenses overview
Subscription plans overview
Support tickets overview
Feature flags overview
```

Not allowed:

```text
Private market debts
Private market payments
Private customer records
Debt ledger entries
Receipts
Evidence files
Customer timeline
```

### market_manager

Allowed:

```text
Market dashboard
Customers
Add debt
Receive payment
Approval Center
Audit Log
Customer Profile
Evidence Vault
Receipts
Smart Lock
```

Scope:

```text
Only own market_id
```

### employee

Allowed:

```text
Market dashboard
Customers
Add debt
Receive payment
Customer Profile
Receipts
Evidence note entry if permitted later
```

Not allowed by default:

```text
Approval Center
Audit Log
Owner Panel
Schema Health
License management
```

Scope:

```text
Only own market_id
```

### customer

Allowed:

```text
Customer portal only
Own statement
Own receipts
Own balance
```

Not allowed:

```text
Manager dashboard
Owner Panel
Other customers
Audit Log
Approval Center
Debt creation
Payment creation
```

## Frontend hardening implemented

```text
AppPermissions helper
AccessDeniedView
Dashboard action visibility by role
Owner Panel role guard
Schema Health role guard
```

## Backend rules still required in PocketBase

Frontend checks are not enough. PocketBase API rules must enforce the same restrictions:

```text
@request.auth.system_role = "system_owner"
@request.auth.market_id = market_id
@request.auth.id = customer_id
```

System owner must never receive read rules for customer/debt/payment/ledger/receipt/evidence collections.
