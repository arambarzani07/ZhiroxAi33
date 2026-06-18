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
- Customer create/edit frontend screen
- Customer create/edit service methods
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
- Kurdish RTL receipt PDF layout
- Optional receipt PDF font loader
- Evidence Vault service and screen
- SaaS Owner service
- SaaS Owner Panel screen
- Owner Panel linked to Schema Health
- PocketBase setup guide
- PocketBase schema collections JSON baseline
- PocketBase API rules baseline
- PocketBase API rules setup guide
- Schema Health service and screen
- Role permission helper
- Access denied view
- Dashboard action visibility by role
- Guarded Add Debt screen
- Guarded Receive Payment screen
- Guarded Customer List screen
- Guarded Approval Center screen
- Guarded Audit Log screen
- Owner Panel direct role guard
- Schema Health direct role guard
- Role permission matrix documentation
- Frontend completion checklist
- Dashboard avoids debt/payment/customer queries for non-market roles
- GitHub Actions Flutter web check workflow
- GitHub Actions manual workflow dispatch
- Flutter doctor step added to CI
- Flutter analyze passes in CI
- Flutter web release build passes in CI
- Compile and build check guide
- Risk score progress type fixed for compile safety
- Evidence quality progress type fixed for compile safety
- Customer initial analyzer issue fixed
- Flutter 3.44 CardThemeData compile issue fixed
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

## Current CI status

```text
flutter pub get: success
flutter analyze: success
flutter build web --release: success
```

## PocketBase backend status

```text
schema_collections.json: ready
api_rules.json: ready
POCKETBASE_API_RULES_SETUP.md: ready
manual PocketBase Admin UI application: still required
```

## Frontend status

```text
Main market workflow screens: implemented
Owner workflow screens: implemented
Role-based Dashboard navigation: implemented
Guarded navigation layer: implemented
Frontend completion checklist: ready
Receipt PDF Kurdish RTL foundation: implemented
Customer create/edit frontend: implemented
```

## PDF receipt status

```text
Kurdish RTL layout: implemented
Official receipt fields: implemented
Verification code and URL: implemented
Optional font asset loading: implemented
Final production font asset: still required before PDF QA
```

## Next frontend modules

```text
1. Market settings/profile frontend screen
2. Customer portal read-only frontend screen
3. Reports/exports frontend foundation
4. Notification center frontend screen
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