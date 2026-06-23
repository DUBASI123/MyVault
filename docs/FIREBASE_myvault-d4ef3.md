# Firebase — myvault-d4ef3

Console: https://console.firebase.google.com/u/4/project/myvault-d4ef3/overview

## Checklist

- [x] Android app package **`com.example.myvault`** (matches Firebase)
- [x] **`google-services.json`** → `android/app/google-services.json`
- [x] Keys in `lib/firebase_options.dart` and VS Code launch config
- [ ] **Authentication** → **Phone** enabled (required for SMS OTP on all installs)

## Who can verify?

Any user who installs the app (any Android phone, emulator, or iOS) gets the same OTP flow. Firebase keys are embedded in the app — no per-device setup.

## Run / build

Keys are already in the project. Just build and share:

```powershell
flutter build apk --debug
```

Or use VS Code launch: **My Vault (Firebase myvault-d4ef3)**

## Test number (no SMS cost)

Authentication → Sign-in method → Phone → **Phone numbers for testing**

| Phone | OTP |
|-------|-----|
| +91 9876543210 | 123456 |
