# My Vault App

Student academic platform — Flutter frontend with Supabase/Firebase integration and Node.js REST API scaffold.

## Features

| Module | Status |
|--------|--------|
| Auth (login, 3-step register, OTP UI, forgot password) | ✅ UI + mock / Supabase fallback |
| Dashboard + bottom nav | ✅ Dark theme + watermark |
| Academic Hub (subjects, PDF, video, admin upload) | ✅ Mock content + Supabase-ready |
| Results, Internships, Projects | ✅ |
| Profile, Notifications, Competitive Exams | ✅ |
| Dark theme (`#0A0A0F`, `#6C63FF`) + institute watermark | ✅ |

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.x, Riverpod, go_router |
| Auth / DB | Supabase (when configured) |
| OTP / FCM | Firebase (when configured) |
| PDF / Video | pdfx, video_player |
| Backend API | Node.js, Express, Prisma, PostgreSQL |
| Storage | flutter_secure_storage, shared_preferences |

## Quick Start

```bash
flutter pub get
flutter run
```

**Mock login:** any non-empty password → demo student (`Dubasi Shivashankar`, CSE Sem 3).

## Production Configuration

Pass keys at build/run time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=FIREBASE_API_KEY=your_firebase_key \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=API_BASE_URL=http://your-api:5000/api
```

Or run `flutterfire configure` and replace placeholders in `lib/firebase_options.dart`.

### Supabase

1. Create a Supabase project
2. Run `supabase/schema.sql` in the SQL Editor
3. Create storage bucket `academic-files` (public read for PDFs/videos)
4. Pass `SUPABASE_URL` and `SUPABASE_ANON_KEY` as above

### Firebase

1. Create a Firebase project
2. Enable Phone Auth + Cloud Messaging
3. Run `flutterfire configure` or pass `--dart-define` keys

### Node.js Backend

```bash
cd backend
cp .env.example .env   # set DATABASE_URL, JWT_SECRET
npm install
npx prisma db push
npm run dev            # http://localhost:5000
```

API routes: `/api/auth/*`, `/api/master/*`, `/api/academic/*`

## Build APK

```bash
flutter build apk --debug
# output: build/app/outputs/flutter-apk/app-debug.apk
```

> Android uses AGP **8.11.1** (required for `file_picker` + AndroidX compatibility).

## Project Structure

```
lib/
├── core/           config, services, theme, router, mock, storage
├── shared/         models, widgets (AppScaffold, watermark, header)
├── features/       splash, auth, dashboard, academic_hub, ...
backend/            Express + Prisma REST API
supabase/           SQL schema
```

## Academic Hub Demo

After login → **Academic Hub** → **Data Structures** → sample PDF notes + video.

## Business Rules

- Display name format: `LastName FirstName`
- Institute logo watermark (~8% opacity) on authenticated screens
- Default password concept: hall ticket number
