# Live OTP Setup — My Vault

OTP works for **anyone who installs and opens the app** — Android, iOS, or web. No device-specific setup for end users.

Real OTP requires at least **one** provider below. Mock OTP (any 6 digits) is disabled when live providers are configured.

## Who gets OTP?

| User action | What happens |
|-------------|--------------|
| Install APK / open app | Firebase keys are already embedded — phone OTP ready once Phone Auth is enabled in console |
| Register / forgot password | Mobile → SMS OTP · Email → inbox OTP |
| Any phone brand | Same flow — Samsung, Redmi, iPhone, emulator, etc. |

---

## Option A — Firebase Phone OTP (default for mobile)

Works for **every app install** without pointing users at your PC.

### 1. Firebase project (already done)
- Project: **myvault-d4ef3**
- Package: **com.example.myvault**
- Keys in `lib/firebase_options.dart` and `android/app/google-services.json`

### 2. Enable Phone Authentication
1. [Firebase Console](https://console.firebase.google.com/u/4/project/myvault-d4ef3/authentication/providers) → **Authentication** → **Sign-in method**
2. Enable **Phone** → Save

### 3. Build and share the APK
```powershell
flutter build apk --debug
```
Anyone who installs `app-debug.apk` can verify their mobile number via SMS.

### Test number (no SMS cost)
Authentication → Phone → **Phone numbers for testing**

| Phone | OTP |
|-------|-----|
| +91 9876543210 | 123456 |

---

## Option B — Supabase Email OTP

Works for any user with an email address.

### 1. Supabase project
1. [supabase.com](https://supabase.com) → New project
2. **Authentication** → **Providers** → enable **Email** with OTP
3. Run `supabase/schema.sql` in SQL Editor

### 2. Build with keys (baked into APK)
```powershell
flutter build apk --dart-define=SUPABASE_URL=https://xxxx.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

---

## Option C — Node.js backend + SMS/Email (optional fallback)

Use when you host your own API (e.g. Railway, Render). Good for custom SMS routing (Fast2SMS India, Twilio global).

### 1. Deploy backend
```powershell
cd backend
cp .env.example .env
npm install
npx prisma db push
npm run dev
```

### 2. Configure live delivery in `backend/.env`

**India SMS (Fast2SMS):**
```
FAST2SMS_API_KEY=your_api_key
```

**Global SMS (Twilio):**
```
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=
```

**Email OTP (SMTP):**
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=you@gmail.com
SMTP_PASS=app_password
SMTP_FROM=My Vault <you@gmail.com>
```

### 3. Build APK with public API URL
```powershell
flutter build apk --dart-define=API_BASE_URL=https://your-api.example.com/api
```

---

## OTP flow in the app

| Channel | Provider priority |
|---------|-------------------|
| Mobile | Firebase Phone → Backend SMS |
| Email | Supabase Email OTP → Backend SMTP |

Registration **requires both** mobile and email verified before Step 2.

Phone numbers: 10-digit Indian numbers auto-format to `+91`. Users can also enter full international format (`+1…`, `+44…`, etc.).

---

## Troubleshooting

- **OTP not received:** Confirm Phone Auth is enabled in Firebase console
- **Invalid phone:** Use `+91` or 10-digit Indian mobile; or full `+country` format
- **Email OTP:** Check spam folder; confirm Supabase keys in build
- **Backend fallback:** Ensure `API_BASE_URL` is a public HTTPS URL, not `localhost`
