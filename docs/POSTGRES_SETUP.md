# PostgreSQL Setup — My Vault Backend

The backend uses **PostgreSQL** (via Prisma). Default connection in `.env`:

```
DATABASE_URL="postgresql://postgres:password@localhost:5432/myvault_db?schema=public"
```

Change `password` to match your PostgreSQL user password.

---

## Option A — Docker (easiest)

```powershell
cd backend
docker compose up -d
npm run setup
npm run dev
```

---

## Option B — Install PostgreSQL on Windows

1. Download [PostgreSQL for Windows](https://www.postgresql.org/download/windows/)
2. Install with default port **5432**
3. Remember the **postgres** user password you set during install
4. Open **pgAdmin** or **SQL Shell (psql)** and create the database:

```sql
CREATE DATABASE myvault_db;
```

5. Update `backend/.env`:

```
DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/myvault_db?schema=public"
```

6. Create database (if needed) and apply schema:

```powershell
cd backend
npm run db:create
npm run setup
npm run verify:live
npm run dev
```

---

## Option C — Cloud PostgreSQL (production)

Use [Neon](https://neon.tech), [Supabase](https://supabase.com), or [Railway](https://railway.app):

1. Create a PostgreSQL database
2. Copy the connection string into `DATABASE_URL`
3. Run `npm run setup` on the server or locally against that URL

---

## Commands

| Command | Description |
|---------|-------------|
| `npm run db:create` | Create `myvault_db` database |
| `npm run setup` | Generate client, push schema, seed data |
| `npm run db:push` | Apply schema changes |
| `npm run db:seed` | Seed universities, colleges, subjects, etc. |
| `npm run db:studio` | Prisma Studio GUI |
| `npm run verify:live` | Test all API tools |

---

## Troubleshooting

**`Can't reach database server`** — PostgreSQL is not running. Start the service or Docker container.

**`Authentication failed`** — Wrong password in `DATABASE_URL`.

**`Database myvault_db does not exist`** — Run `npm run db:create` or `CREATE DATABASE myvault_db;` in psql/pgAdmin.

**Prisma EPERM on Windows** — Close other Node processes, then run `npx prisma generate` again.
