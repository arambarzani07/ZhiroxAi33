# Compile and Build Checks

This project includes a GitHub Actions workflow for Flutter analysis and web build.

## Workflow

```text
.github/workflows/flutter_web_check.yml
```

## What it runs

```bash
flutter doctor -v
flutter pub get
flutter analyze --no-fatal-infos
flutter build web --release --dart-define=POCKETBASE_URL=<secret-or-fallback-url>
```

## Manual run

The workflow supports manual execution through GitHub Actions because `workflow_dispatch` is enabled.

## Recommended GitHub secret

Add this repository secret before production builds:

```text
POCKETBASE_URL=https://your-pocketbase-url
```

If the secret is missing, the workflow falls back to the current Railway PocketBase URL so the compile check can still run.

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
Risk score progress value is typed as double.
Evidence quality progress value is typed as double.
```

## Remaining expected compile/build work

```text
Run GitHub Actions and inspect logs.
Fix package/API mismatches reported by flutter analyze.
Confirm PocketBase collection fields exist through Schema Health.
Embed Kurdish PDF font before final receipt PDFs.
```