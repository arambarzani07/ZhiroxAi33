# Start Here — Zhirox AI Debt

This repository is connected as the clean working repository for Zhirox AI Debt.

## Current status

- Repository is initialized.
- Flutter-safe `.gitignore` is added.
- Official README is added.
- Next step is adding the Flutter source code and app/web foundation files.

## Recommended workflow

1. Keep `main` stable.
2. Create feature branches for each safe module.
3. Add code module by module.
4. Test after every module.
5. Merge only after the app still runs.

## First implementation modules

```text
1. Flutter app/web source foundation
2. Responsive layout foundation
3. PocketBase configuration
4. Auth and role routing
5. Customers
6. Debts
7. Payments
8. Ledger
9. Audit logs
10. Approval center
```

## Production rules

- No fake production data.
- No silent debt editing.
- No debt deletion without audit/approval/correction.
- Every financial action must create ledger and audit records.
- Kurdish Sorani RTL must stay consistent across app and web.
