# PocketBase Setup — Zhirox AI Debt

This folder contains the implementation baseline for the required PocketBase collections.

## Important

The Flutter code expects these collections to exist before production testing:

```text
users
markets
debts
payments
notifications
audit_logs
debt_ledger_entries
approvals
receipts
customer_scores
smart_locks
lock_history
evidence_files
dispute_cases
subscription_plans
licenses
support_tickets
feature_flags
```

## Safe setup rule

Do not delete old data or old collections. Add missing collections and missing fields only.

## Recommended process

1. Open PocketBase Admin UI.
2. Create missing collections from `schema_collections.json`.
3. Add fields exactly as listed.
4. Configure API rules by role and `market_id`.
5. Create one `system_owner` user.
6. Create one test market.
7. Create one `market_manager` user with `market_id`.
8. Run the app and open Owner Panel -> Schema Health.

## Required first users

```text
system_owner: manages SaaS only
market_manager: manages one market
employee: creates allowed debt/payment records
customer: reads only own portal data
```

## Privacy rule

The system owner must not read private market debt, payment, customer, ledger, receipt, or evidence data. Owner tools should use markets, licenses, support tickets, plans, feature flags, and aggregate usage only.
