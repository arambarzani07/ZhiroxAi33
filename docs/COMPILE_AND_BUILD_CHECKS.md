# Compile and Build Checks

This project now includes a GitHub Actions workflow for Flutter analysis and web build.

## Workflow

```text
.github/workflows/flutter_web_check.yml
```

## What it runs

```bash
flutter pub get
flutter analyze
flutter build web --release --dart-define=POCKETBASE_URL=${{ secrets.POCKETBASE_URL }}
```

## Required GitHub secret

Add this repository secret before production builds:

```text
POCKETBASE_URL=https://your-pocketbase-url
```

## Local test commands

```bash
flutter pub get
flutter analyze
flutter build web --release
```

## Compile hardening already applied

```text
Dashboard does not query market debt/payment/customer stats for non-market roles.
Owner role is routed to Owner Panel.
Schema Health is owner-only.
Owner Panel is owner-only.
Role permission helper centralizes frontend rules.
Access Denied screen protects direct navigation.
```

## Remaining expected compile/build work

```text
Run GitHub Actions and inspect logs.
Fix package/API mismatches reported by flutter analyze.
Confirm PocketBase collection fields exist through Schema Health.
Embed Kurdish PDF font before final receipt PDFs.
```
