# PocketBase API Rules Setup — Zhirox AI Debt

This guide converts the role/privacy design into PocketBase collection API rules.

PocketBase API rules are collection-level access controls. Each collection has:

```text
listRule
viewRule
createRule
updateRule
deleteRule
```

Auth collections also have a management rule. Use the PocketBase Admin UI collection API Rules tab to paste the rules from:

```text
pocketbase/api_rules.json
```

## Critical security rule

Never use a PocketBase superuser account in the public Flutter app. PocketBase superusers bypass API rules.

## Role fields required on users

Every user record must have:

```text
system_role: system_owner | market_manager | employee | customer
market_id: relation -> markets, required for market_manager and employee
```

Customer users should also have enough identity fields for portal rules, and any customer-facing collections should store `customer_id`.

## Global rule patterns

### Authenticated user

```text
@request.auth.id != ''
```

### Same market record

```text
market_id = @request.auth.market_id
```

### Same market create

```text
@request.body.market_id = @request.auth.market_id
```

### Manager or employee

```text
(@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')
```

### Manager only

```text
@request.auth.system_role = 'market_manager'
```

### Customer own record

```text
customer_id = @request.auth.id
```

## Owner privacy

System owner may access SaaS operations only:

```text
markets
subscription_plans
licenses
support_tickets
feature_flags
```

System owner must not receive list/view rules for private market data:

```text
debts
payments
debt_ledger_entries
receipts
evidence_files
customer_scores
smart_locks
lock_history
approvals
audit_logs
dispute_cases
```

## Financial collections

### debts

```text
listRule: market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')
viewRule: (market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')) || (customer_id = @request.auth.id && @request.auth.system_role = 'customer')
createRule: @request.body.market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')
updateRule: market_id = @request.auth.market_id && @request.auth.system_role = 'market_manager'
deleteRule: locked/null
```

### payments

```text
listRule: market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')
viewRule: (market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')) || (customer_id = @request.auth.id && @request.auth.system_role = 'customer')
createRule: @request.body.market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')
updateRule: market_id = @request.auth.market_id && @request.auth.system_role = 'market_manager'
deleteRule: locked/null
```

### debt_ledger_entries

Ledger entries should be append-only:

```text
listRule: (market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')) || (customer_id = @request.auth.id && @request.auth.system_role = 'customer')
viewRule: same as listRule
createRule: @request.body.market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')
updateRule: locked/null
deleteRule: locked/null
```

## Audit collections

### audit_logs

Audit must be immutable after creation:

```text
listRule: market_id = @request.auth.market_id && @request.auth.system_role = 'market_manager'
viewRule: market_id = @request.auth.market_id && @request.auth.system_role = 'market_manager'
createRule: @request.body.market_id = @request.auth.market_id && (@request.auth.system_role = 'market_manager' || @request.auth.system_role = 'employee')
updateRule: locked/null
deleteRule: locked/null
```

## Setup order

1. Add missing fields to `users`.
2. Create `markets`.
3. Create one `system_owner` user.
4. Create one test market.
5. Create one `market_manager` user linked to that market.
6. Create one employee user linked to that market.
7. Paste rules collection by collection from `pocketbase/api_rules.json`.
8. Test manager login from Flutter.
9. Test employee debt/payment creation.
10. Test that system_owner cannot list debts/payments/customers.
11. Test that customer cannot read other customers.

## Acceptance tests

```text
system_owner can open Owner Panel.
system_owner cannot list debts.
market_manager can list own market debts.
market_manager cannot list another market debts.
employee can create debt/payment for own market.
employee cannot open Approval Center or Audit Log.
customer can view own receipts/ledger only.
ledger entries cannot be updated or deleted from client API.
audit logs cannot be updated or deleted from client API.
```
