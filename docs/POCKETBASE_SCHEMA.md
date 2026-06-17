# PocketBase Schema Baseline — Zhirox AI Debt

This schema is additive. Do not delete existing collections or fields.

## Required existing/core collections

```text
users
debts
payments
notifications
```

## Required new collections

```text
markets
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
```

## users field additions

```text
market_id: relation -> markets
system_role: select(system_owner, market_manager, employee, customer)
permissions: json
active: bool
approved: bool
customer_code: text
portal_enabled: bool
last_login_at: date
```

## debts field additions

```text
market_id: relation -> markets
debt_number: text
ledger_locked: bool
requires_approval: bool
approval_id: relation -> approvals
risk_level_at_creation: text
trust_score_at_creation: number
debt_truth_score: number
evidence_quality: number
archived: bool
archive_reason: text
```

## payments field additions

```text
market_id: relation -> markets
customer_id: relation -> users
receipt_id: relation -> receipts
ledger_entry_id: relation -> debt_ledger_entries
payment_number: text
previous_balance: number
new_balance: number
currency: text
archived: bool
```

## audit_logs

```text
market_id: relation -> markets
actor_user_id: relation -> users
action_type: text
entity_type: text
entity_id: text
before_value: json
after_value: json
reason: text
device_info: json
created_at: date
```

## debt_ledger_entries

```text
market_id: relation -> markets
customer_id: relation -> users
debt_id: relation -> debts
payment_id: relation -> payments
entry_type: select(debt_created, payment_received, correction, discount, forgiveness, opening_balance)
amount: number
previous_balance: number
new_balance: number
currency: text
created_by: relation -> users
audit_log_id: relation -> audit_logs
receipt_id: relation -> receipts
reason: text
created_at: date
```

## approvals

```text
market_id: relation -> markets
request_type: text
entity_type: text
entity_id: text
requested_by: relation -> users
customer_id: relation -> users
amount: number
reason: text
status: select(pending, approved, rejected, cancelled)
manager_note: text
resolved_by: relation -> users
resolved_at: date
created_at: date
```

## smart_locks

```text
market_id: relation -> markets
customer_id: relation -> users
active: bool
risk_level: text
reason: text
locked_by: relation -> users
lock_source: text
created_at: date
unlocked_by: relation -> users
unlocked_at: date
unlock_reason: text
```

## lock_history

```text
market_id: relation -> markets
customer_id: relation -> users
lock_id: relation -> smart_locks
action: select(locked, unlock_requested, unlocked, rejected)
reason: text
actor_user_id: relation -> users
created_at: date
```

## Access rule principle

- System owner may manage markets/licenses/support but must not read private debt/payment/customer records.
- Market manager can read/write records for own `market_id`.
- Employee can create allowed debt/payment records for own `market_id`.
- Customer can read only own portal records.
