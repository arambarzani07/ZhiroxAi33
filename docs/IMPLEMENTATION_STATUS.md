# Implementation Status — Approved Plan

Branch: `implement-approved-plan`

## Implemented foundation

- Flutter project manifest
- Kurdish Sorani RTL app shell
- Responsive mobile/tablet/web foundation
- PocketBase client
- Auth service using `users` collection
- App state provider
- Dashboard using real PocketBase data
- Login screen
- Customer lookup/list/profile
- Customer ledger timeline
- Customer Debt Passport foundation
- Customer risk/trust score UI
- Smart Lock UI
- Unlock request flow to Approval Center
- Add Debt Smart Lock protection
- Receipt creation service
- Receipt history screen
- Receipt QR verification UI
- Receipt PDF foundation service
- Evidence Vault service and screen
- SaaS Owner service
- SaaS Owner Panel screen
- Owner Panel linked to Schema Health
- PocketBase setup guide
- PocketBase schema collections JSON baseline
- Schema Health service and screen
- Role permission helper
- Access denied view
- Dashboard action visibility by role
- Owner Panel direct role guard
- Schema Health direct role guard
- Role permission matrix documentation
- Dashboard avoids debt/payment/customer queries for non-market roles
- GitHub Actions Flutter web check workflow
- Compile and build check guide
- Add debt screen wired to DebtService
- Receive payment screen wired to PaymentService
- Approval Center UI
- Audit Log UI
- Audit service
- Immutable ledger service
- Approval service
- Risk service
- Debt service connected to ledger + audit + receipt
- Payment service connected to ledger + audit + receipt
- PocketBase schema baseline documentation
- Flutter web `web/` files
- Netlify build configuration

## Next modules

```text
1. Read GitHub Actions logs and fix reported compile issues
2. PDF Kurdish font embedding
3. Production QA pass
4. PocketBase API rules setup
```

## Test commands

```bash
flutter pub get
flutter analyze
flutter run -d chrome
flutter build web --release
```

## Netlify

```text
Build command: flutter build web --release
Publish directory: build/web
```