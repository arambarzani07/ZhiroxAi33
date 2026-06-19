# PocketBase Setup — Zhirox AI Debt

This folder contains the implementation baseline for the required PocketBase collections and API rules.

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

## Files

```text
pocketbase/schema_collections.json
pocketbase/api_rules.json
docs/POCKETBASE_API_RULES_SETUP.md
```

## Safe setup rule

Do not delete old data or old collections. Add missing collections and missing fields only.

## Recommended process

1. Open PocketBase Admin UI.
2. Create missing collections from `schema_collections.json`.
3. Add fields exactly as listed.
4. Configure API rules from `api_rules.json`.
5. Read `docs/POCKETBASE_API_RULES_SETUP.md` before production.
6. Create one `system_owner` user.
7. Create one test market.
8. Create one `market_manager` user with `market_id`.
9. Create one `employee` user with `market_id`.
10. Run the app and open Owner Panel -> Schema Health.
11. Test that market users cannot see another market.
12. Test that system owner cannot list private debts/payments/customers.

## Required first users

```text
system_owner: manages SaaS only
market_manager: manages one market
employee: creates allowed debt/payment records
customer: reads only own portal data
```

## Privacy rule

The system owner must not read private market debt, payment, customer, ledger, receipt, or evidence data. Owner tools should use markets, licenses, support tickets, plans, feature flags, and aggregate usage only.

## Superuser warning

Never use a PocketBase superuser account inside the public Flutter app. PocketBase superusers bypass API rules.