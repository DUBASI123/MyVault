# My Vault Backend

Express REST API with Prisma ORM and PostgreSQL.

Full guide: [docs/BACKEND_SETUP.md](../docs/BACKEND_SETUP.md)

## Setup

```bash
cp .env.example .env
npm install
```

Start PostgreSQL (Docker or local install) — see [docs/POSTGRES_SETUP.md](../docs/POSTGRES_SETUP.md).

```bash
npm run setup
npm run dev
```

## Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start with hot reload |
| `npm start` | Production start |
| `npm run setup` | Generate client, push schema, seed data |
| `npm run db:seed` | Seed universities/colleges/subjects |
| `npm run db:studio` | Prisma Studio GUI |

## Auth endpoints

- `POST /api/auth/register` — verify OTP first, returns JWT + student
- `POST /api/auth/login` — email / hall ticket / mobile + password
- `POST /api/auth/send-otp` — SMS or email OTP
- `POST /api/auth/verify-otp` — verify code
- `POST /api/auth/reset-password` — reset with OTP
- `GET /api/auth/me` — current user (Bearer token)

In development, OTP codes are returned as `otpPreview` when SMS/email is not configured.
