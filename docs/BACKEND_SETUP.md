# My Vault Backend — Full Setup

Real REST API for auth, OTP, master data, and academic content.

## Stack

| Tool | Purpose |
|------|---------|
| **Express 5** | HTTP API |
| **Prisma 6** | PostgreSQL ORM |
| **JWT** | Session tokens |
| **bcryptjs** | Password hashing |
| **Twilio / Fast2SMS** | Live SMS OTP |
| **Nodemailer** | Live email OTP |
| **express-validator** | Request validation |

## Quick start (local)

```powershell
cd backend
cp .env.example .env
npm install
npm run setup
npm run dev
```

API runs at `http://localhost:5000/api`

Health check: `GET http://localhost:5000/api/health`

**Verify all tools are live:**
```powershell
npm run verify:live
```

Detailed status: `GET http://localhost:5000/api/health/live`

## Connect Flutter app

**Emulator:**
```powershell
flutter run --dart-define=USE_LOCAL_BACKEND=true `
  --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
```

**Physical phone (same Wi‑Fi as PC):**
```powershell
flutter run --dart-define=USE_LOCAL_BACKEND=true `
  --dart-define=API_BASE_URL=http://YOUR_PC_IP:5000/api
```

**Production APK (deploy backend first):**
```powershell
flutter build apk --dart-define=API_BASE_URL=https://your-api.example.com/api
```

When backend is configured, **all OTP** (mobile + email) and **auth** go through the API.

---

## Auth flow

### Register
1. `POST /auth/send-otp` — mobile `{ target: "+91...", purpose: "register" }`
2. `POST /auth/verify-otp` — marks OTP verified
3. Repeat for email
4. `POST /auth/register` — creates student with `isMobileVerified` / `isEmailVerified`
5. Returns `{ token, student }` — auto-login

### Login
`POST /auth/login` — `{ identifier, password }`  
Identifier: email, hall ticket, or mobile.

### Forgot password
1. `POST /auth/send-otp` — `{ target, purpose: "reset" }`
2. `POST /auth/verify-otp` — checks OTP (does not consume for reset)
3. `POST /auth/reset-password` — `{ identifier, otp, newPassword, target }`

### Profile
`GET /auth/me` — Bearer token required

---

## API reference

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/health` | No | Health check |
| POST | `/api/auth/register` | No | Create account |
| POST | `/api/auth/login` | No | Login |
| POST | `/api/auth/send-otp` | No | Send SMS/email OTP |
| POST | `/api/auth/verify-otp` | No | Verify OTP |
| POST | `/api/auth/reset-password` | No | Reset password |
| GET | `/api/auth/me` | Bearer | Current student |
| GET | `/api/master/universities` | No | List universities |
| GET | `/api/master/colleges?universityId=` | No | List colleges |
| GET | `/api/academic/subjects?branch=&semester=` | No | List subjects |
| GET | `/api/academic/contents/:subjectId` | No | List content |
| POST | `/api/academic/contents` | Bearer | Upload content metadata |

---

## Environment (`.env`)

| Variable | Required | Description |
|----------|----------|-------------|
| `PORT` | No | Default 5000 |
| `NODE_ENV` | No | `development` shows OTP in API response |
| `DATABASE_URL` | Yes | PostgreSQL connection string (see [POSTGRES_SETUP.md](../docs/POSTGRES_SETUP.md)) |
| `JWT_SECRET` | Yes | Change in production |
| `JWT_EXPIRES_IN` | No | Default `7d` |
| `CORS_ORIGIN` | No | Default `*` |
| `FAST2SMS_API_KEY` | For India SMS | [fast2sms.com](https://www.fast2sms.com) |
| `TWILIO_*` | For global SMS | Twilio account |
| `SMTP_*` | For email OTP | Gmail app password works |

In **development**, if SMS/email is not configured, OTP appears as `otpPreview` in the API response.

---

## Database

```powershell
npm run db:push      # Apply schema
npm run db:seed      # Universities, colleges, subjects
npm run db:studio    # Prisma GUI
```

Seed IDs match the Flutter app (`universityId: "1"`, `collegeId: "c1"`, etc.).

---

## Deploy (production)

1. Create PostgreSQL database (Railway, Supabase, Neon, etc.)
2. Set env vars on host
3. Run `npm run setup && npm start`
4. Build Flutter APK with public `API_BASE_URL`
5. Set `NODE_ENV=production` (hides OTP preview)

---

## File structure

```
backend/
├── prisma/
│   ├── schema.prisma    # Database models
│   └── seed.js          # Sample data
├── src/
│   ├── server.js        # Entry point
│   ├── controllers/
│   │   └── auth.controller.js
│   ├── middleware/
│   │   ├── auth.middleware.js
│   │   └── validate.js
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── master.routes.js
│   │   └── academic.routes.js
│   ├── services/
│   │   └── otp_delivery.service.js
│   └── lib/
│       ├── prisma.js
│       └── phone.js
├── .env.example
└── package.json
```
