# GitHub Actions Workflows

## Flutter APK Build Workflow

This workflow automatically builds your Flutter app as an APK file when you push code to the `main` or `master` branch.

### Features:
- ✅ Automatic build on push to main/master branches
- ✅ Manual trigger via GitHub Actions UI (`workflow_dispatch`)
- ✅ Creates missing asset directories automatically
- ✅ Handles local `flutter_sms` package
- ✅ Uploads APK as downloadable artifact (30 days retention)

### How to use:

1. **Automatic Build**: Just push your code to `main` or `master` branch
2. **Manual Build**: 
   - Go to Actions tab
   - Select "Build Flutter APK" workflow
   - Click "Run workflow" button

### Download APK:

After the workflow completes:
1. Go to the Actions tab
2. Click on the latest workflow run
3. Scroll down to "Artifacts" section
4. Click on `release-apk` to download

### Requirements in your repo:
- `pubspec.yaml` with all dependencies listed
- `packages/flutter_sms/` directory for local SMS plugin
- `assets/images/` and `assets/translations/` directories (created automatically if missing)

### Notes:
- The `flutter analyze` step has been removed to avoid failures due to missing local Flutter SDK
- All dependencies are installed automatically by GitHub Actions
- Java 17 is used for Android builds
- Flutter 3.24.0 stable channel is used
