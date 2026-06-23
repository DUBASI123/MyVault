# My Vault — Live Setup (All Real)

Everything runs against real services — no mock login, no fake data when `LIVE_MODE=true` (default).

## Stack (live)

| Layer | Service | Purpose |
|-------|---------|---------|
| **App** | Flutter | UI + OTP badges |
| **Auth & data** | Node.js + PostgreSQL | Register, login, OTP, results, internships |
| **Phone OTP** | Firebase `myvault-d4ef3` | SMS when backend SMS not configured |
| **Push** | Firebase Cloud Messaging | Notifications (when enabled) |

## 1. Start backend

```powershell
cd backend
npm install
npm run setup
npm run dev
```

Requires **PostgreSQL** — see [POSTGRES_SETUP.md](POSTGRES_SETUP.md).

Verify everything is live:
```powershell
cd backend
npm run verify:live
```

Dev OTP appears in API response as `otpPreview` until you add `FAST2SMS_API_KEY` or SMTP.

## 2. Run app (live)

VS Code → **My Vault (Live)** — connects to `http://10.0.2.2:5000/api` (emulator).

Physical phone on same Wi‑Fi → edit IP in **My Vault (Live — physical phone)** launch config.

## 3. Build live APK

```powershell
.\scripts\build_live_apk.ps1 -ApiUrl "http://YOUR_PC_IP:5000/api"
```

Replace `YOUR_PC_IP` with output of `ipconfig` (Wi‑Fi IPv4).

## 4. Firebase console

Enable **Authentication → Phone** for SMS OTP on installs without backend SMS.

## What is live in the app

- Register / login / forgot password → **backend API**
- Mobile + email OTP → **backend** (or Firebase phone if backend off)
- Universities / colleges → **backend `/api/master`**
- Academic subjects & content → **backend `/api/academic`**
- Notifications ticker & list → **backend `/api/content`**
- Exam results → **backend `/api/content/results`**
- Internships → **backend `/api/content/internships`**
- JWT session → stored in secure storage

## Production deploy

1. Deploy backend (Railway, Render, VPS) with PostgreSQL
2. Set `NODE_ENV=production`, `JWT_SECRET`, SMS/email keys
3. Build APK: `flutter build apk --dart-define=API_BASE_URL=https://your-api.com/api`

See also: [BACKEND_SETUP.md](BACKEND_SETUP.md), [OTP_SETUP.md](OTP_SETUP.md)
