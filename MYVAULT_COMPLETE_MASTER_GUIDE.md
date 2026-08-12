# 📘 MyVault — Complete End-to-End System Master Guide

This guide details everything about the **MyVault Ecosystem**: what it is, how it was built, what tools and technologies were used, the frontend, backend, database, cloud storage, API endpoints, architecture, and step-by-step build process.

---

## 🎯 1. Project Overview & Purpose

**MyVault** is an enterprise-grade academic platform and digital vault for engineering and degree students. It bridges mobile users (Android app) and web users (faculty/students web portal) to access study materials, notes, lab manuals, question banks, placement updates, and government job alerts.

### 🌟 Core Capabilities
- **Academic Hub**: Year → Semester → Branch → Subject structured study material browsing.
- **Direct S3 Upload Portal**: Faculty drag-and-drop file upload directly to AWS S3 using presigned URLs.
- **Placements & Jobs Hub**: Campus placement drives, tech/core internships, and government exam notifications.
- **Student Auth**: Student authentication (Login & Self-Registration) with course toggles and standard hall ticket validation.
- **Dual Cloud Redundancy**: Primary AWS (RDS PostgreSQL + S3) with instant fallback to Supabase (Database + Bucket).
- **Direct APK Streaming**: Self-hosted APK delivery from backend server or S3 fallback.

---

## 🛠️ 2. Technologies & Tools Used

### 📱 A. Mobile App Technology Stack
- **Framework**: Flutter 3.x with Dart 3.x.
- **State Management**: `flutter_riverpod` (`^2.5.1`) using `AsyncNotifier` for clean async lifecycle handling.
- **Navigation**: `go_router` (`^13.2.0`) with declarative route guards and instant redirect logic.
- **Networking**: `dio` (`^5.4.3+1`) for NestJS API REST calls & `http` for presigned S3 streaming.
- **Secure Storage**: `flutter_secure_storage` (`^9.0.0`) for encrypted JWT token persistence.
- **Dual Database Client**: `supabase_flutter` (`^2.8.4`) for direct Supabase fallback.

### ⚙️ B. Backend API Technology Stack
- **Framework**: NestJS (`v10.4.15`) running on Node.js 20 LTS (Express platform).
- **ORM**: Prisma ORM (`v5.22.0`) for type-safe database queries.
- **Cloud Storage SDK**: `@aws-sdk/client-s3`, `@aws-sdk/s3-request-presigner`, `@aws-sdk/lib-storage` (AWS SDK v3).
- **API Docs**: `@nestjs/swagger` (`v8.1.0`) auto-generating interactive Swagger OpenAPI UI at `/api/docs`.
- **Middleware**: Gzip/Brotli `compression`, CORS headers, `ValidationPipe`, static file serving via `@nestjs/serve-static`.

### 🌐 C. Web Frontend Technology Stack
- **Framework**: Next.js 16 App Router (`output: 'export'`) with React 19 & TypeScript.
- **Styling**: Tailwind CSS v4 + Vanilla Glassmorphic CSS design tokens (`globals.css`).
- **Icons**: `lucide-react`.
- **Export Target**: Pre-rendered static HTML/CSS/JS output compiled to `backend/public/`.

### 🚢 D. DevOps, Cloud & Infrastructure
- **Cloud Hosting Platform**: Render (Docker container deployment).
- **Containerization**: Multi-stage Docker build (`Dockerfile`) based on `node:20-alpine` with `openssl` and `libc6-compat`.
- **Database Server**: AWS RDS PostgreSQL (`ap-south-1`).
- **Object Storage**: AWS S3 Bucket (`myvault-study-materials`).
- **Version Control**: Git & GitHub (`DUBASI123/MyVault`).

---

## 🗄️ 3. Database Architecture (AWS RDS PostgreSQL)

Database schemas are managed using **Prisma ORM** (`backend/prisma/schema.prisma`):

```prisma
model Student {
  id               String   @id @default(uuid())
  hallTicketNumber String   @unique
  fullName         String   // Formatted "Lastname Firstname"
  email            String   @unique
  phone            String?
  courseType       String   @default("btech") // btech | degree
  branch           String   // ECE, CSE, AI & ML, EEE, MECH, CIVIL
  semester         Int      // 1 through 8
  passwordHash     String
  createdAt        DateTime @default(now())
}

model Subject {
  id          String            @id @default(uuid())
  name        String
  code        String
  branch      String
  semester    Int
  subjectType String            @default("academic")
  contents    AcademicContent[]
}

model AcademicContent {
  id          String   @id @default(uuid())
  subjectId   String
  subject     Subject  @relation(fields: [subjectId], references: [id])
  title       String
  contentType String   // NOTES | QUESTION_BANK | SYLLABUS | LAB_MANUAL
  unitNumber  Int?
  fileUrl     String   // AWS S3 Public GET URL
  storagePath String?  // AWS S3 Bucket Key (downloads/...)
  description String?
  createdAt   DateTime @default(now())
}

model Notification {
  id        String   @id @default(uuid())
  title     String
  message   String
  category  String   @default("general")
  createdAt DateTime @default(now())
}

model ExamResult {
  id        String   @id @default(uuid())
  studentId String
  semester  Int
  gpa       Float
  status    String
  createdAt DateTime @default(now())
}

model Internship {
  id          String   @id @default(uuid())
  title       String
  company     String
  type        String   // IT | Core | Govt
  link        String
  createdAt   DateTime @default(now())
}
```

---

## ☁️ 4. Cloud Storage Architecture (AWS S3)

- **Bucket Name**: `myvault-study-materials`
- **Region**: `ap-south-1` (Mumbai)
- **S3 Security Model**:
  - **Direct Uploads**: The client (web browser or mobile app) requests a 5-minute signed `PUT` URL from `GET /api/s3/presign-upload`. The client streams the file bytes directly to AWS S3 without overloading the API server.
  - **Downloads & Inline View**: Files are accessed via presigned GET URLs (`GET /api/s3/download/*`, `GET /api/s3/view/*`) or direct public bucket S3 links.
  - **Bucket CORS Rules**: Enabled for `GET, PUT, POST, DELETE, HEAD` from `*` origins to allow direct web browser uploads.

---

## 🔌 5. Complete Backend REST API Endpoints

### 🩺 System & APK Delivery
- `GET /` — Serves static Next.js website landing page.
- `GET /health` — Returns JSON server health status (`{ status: "online" }`).
- `GET /download-apk` — Streams `MyVault-release.apk` (52.4 MB) directly from server disk with S3 fallback.
- `GET /api/docs` — Interactive Swagger OpenAPI documentation UI.

### 🔑 Auth Controller (`/api/auth`)
- `POST /api/auth/register` — Creates new student record in RDS PostgreSQL.
- `POST /api/auth/login` — Verifies hall ticket & password, returns JWT token.
- `POST /api/auth/reset-password` — Password reset.
- `GET /api/auth/me` — Fetches current authenticated student profile.

### 📚 Academic Controller (`/api/academic`)
- `GET /api/academic/subjects` — Query subjects by `branch`, `semester`, and `type`.
- `GET /api/academic/subjects/:id/contents` — Fetch study materials for a given subject.
- `POST /api/academic/contents` — Register uploaded file metadata into RDS PostgreSQL.

### ☁️ Storage Controller (`/api/s3`)
- `GET /api/s3/presign-upload` — Generate 5-min presigned `PUT` upload URL.
- `GET /api/s3/download/*` — Generate download URL for S3 key.
- `GET /api/s3/view/*` — Generate inline view URL for S3 key.
- `DELETE /api/s3/object/*` — Remove object from S3.

### 📰 Content & Master Controllers (`/api/content` & `/api/master`)
- `GET /api/content/notifications` — Fetch college notices.
- `GET /api/content/results` — Fetch student exam result records.
- `GET /api/content/internships` — Fetch placement & job listings.
- `GET /api/master/universities` — Master list of universities.
- `GET /api/master/colleges` — Master list of colleges.

---

## 🏗️ 6. How the System Was Built (Step-by-Step)

### Step 1: Database & ORM Setup
1. Created `schema.prisma` modeling students, subjects, contents, results, and notifications.
2. Initialized Prisma Service in NestJS with connection pooling, graceful fallback, and error handling.

### Step 2: Storage Service Implementation
1. Configured `@aws-sdk/client-s3` in `StorageService`.
2. Created presigned `PUT` URL generator (`getPresignedUploadUrl`) and `GET` URL generator (`getPresignedDownloadUrl`).

### Step 3: NestJS Backend API & Serving Layer
1. Implemented Controllers and Services for Auth, Academic, Storage, Master, and Content.
2. Enabled Gzip/Brotli `compression` for 80% payload size reduction.
3. Added `Cache-Control` headers (`public, max-age=300`) to academic endpoints.
4. Integrated `ServeStaticModule` to serve Next.js exported web app directly from `backend/public/`.

### Step 4: Next.js 16 Web Application
1. Created Next.js 16 App Router application in `frontend/`.
2. Built Glassmorphic design system (`globals.css`) with dark theme `#07080D` and electric cyan accents.
3. Created pages: Home Landing Page (`/`), Academic Hub (`/academic`), Placements Portal (`/placements`), AWS S3 Upload Portal (`/upload`), Login (`/auth/login`), Registration (`/auth/register`).
4. Set `output: 'export'` in `next.config.ts` and copied build output from `frontend/out/` into `backend/public/`.

### Step 5: Flutter Mobile Application
1. Implemented Riverpod state management (`authControllerProvider`, `academicServiceProvider`).
2. Configured GoRouter (`app_router.dart`) with instant redirect guards to prevent splash screen hang.
3. Integrated dual-engine fallback logic: primary AWS RDS + S3, fallback to Supabase Database & Storage.
4. Configured native Android permissions in `AndroidManifest.xml` for internet, storage, media, and notifications.
5. Compiled production Release APK (`flutter build apk --release`, 52.4 MB) and copied to `backend/public/MyVault-release.apk`.

### Step 6: Dockerization & Deployment
1. Built Docker container (`Dockerfile`) using Node 20 Alpine Linux with OpenSSL binaries for Prisma engine compatibility.
2. Pushed code to GitHub (`DUBASI123/MyVault`).
3. Deployed automatically to Render cloud hosting at `https://myvault-f08x.onrender.com`.

---

## 🌐 7. Live System Links

- **Live Web Portal**: [https://myvault-f08x.onrender.com](https://myvault-f08x.onrender.com)
- **Live Swagger API Docs**: [https://myvault-f08x.onrender.com/api/docs](https://myvault-f08x.onrender.com/api/docs)
- **Live APK Download**: [https://myvault-f08x.onrender.com/download-apk](https://myvault-f08x.onrender.com/download-apk)
- **GitHub Repository**: [https://github.com/DUBASI123/MyVault](https://github.com/DUBASI123/MyVault)
