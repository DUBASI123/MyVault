# Build live APK — replace YOUR_PC_IP with your Wi-Fi IP (ipconfig)
param(
  [string]$ApiUrl = "http://YOUR_PC_IP:5000/api"
)

flutter build apk --debug `
  --dart-define=LIVE_MODE=true `
  --dart-define=USE_LOCAL_BACKEND=true `
  --dart-define=API_BASE_URL=$ApiUrl `
  --dart-define=FIREBASE_PROJECT_ID=myvault-d4ef3 `
  --dart-define=FIREBASE_API_KEY=AIzaSyDDyL1qmVKSj6xsf1R1CIrwYf45jcZQEG8 `
  --dart-define=FIREBASE_APP_ID=1:516838951262:android:9b83f703940356b41627cf `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=516838951262

Copy-Item "build\app\outputs\flutter-apk\app-debug.apk" "$env:USERPROFILE\Desktop\MyVault-live.apk" -Force
Write-Host "APK copied to Desktop\MyVault-live.apk"
