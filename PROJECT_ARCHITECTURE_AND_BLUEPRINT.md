# 🏛️ MyVault — Complete Technical Architecture, Blueprints & Tooling Specification

This document provides an exhaustive, production-grade breakdown of the **MyVault Enterprise Ecosystem**—comprising the **Flutter Cross-Platform Mobile App**, **NestJS REST API Backend**, and **Next.js 16 App Router Web Application**.

---

## 1. 🛠️ Prerequisites & Development Tools Required

### 💻 System Requirements & SDKs
| Tool / Environment | Version | Purpose |
|---|---|---|
| **Flutter SDK** | `^3.19.0` (Dart 3.x) | Mobile App Compilation (Android APK & iOS) |
| **Node.js** | `v20.x LTS` | Runtime for NestJS Backend & Next.js Frontend |
| **npm** | `v10.x` | Package Manager |
| **Docker & Docker Desktop** | Latest | Containerization & Cloud Deployment |
| **Git** | Latest | Version Control (`origin/main`) |
| **AWS CLI v2** | Latest | Managing AWS S3 Buckets & RDS Databases |
| **PostgreSQL / AWS RDS** | `v15+` | Relational Database Engine |

---

## 2. 🧰 Technology Stack & Libraries

### 📱 A. Mobile Application (Flutter & Dart)
- **State Management**: `flutter_riverpod` (`^2.5.1`) — Decoupled state providers & `AsyncNotifier` controllers.
- **Routing & Navigation**: `go_router` (`^13.2.0`) — Guarded declarative routing (`/splash`, `/login`, `/register`, `/home`, `/dev-settings`).
- **HTTP Client**: `dio` (`^5.4.3+1`) & `http` (`^1.2.1`) — Presigned URL uploads & REST API streaming.
- **Storage & Security**: `flutter_secure_storage` (`^9.0.0`) & `shared_preferences` (`^2.2.3`).
- **File Picker & Downloads**: `file_picker` (`^8.0.0`), `path_provider` (`^2.1.2`), `open_file` (`^3.3.2`).
- **Database Engine**: `supabase_flutter` (`^2.8.4`) — Dual-engine database & storage fallback.

### ⚙️ B. Backend API Server (NestJS, TypeScript & Prisma ORM)
- **Framework**: NestJS (`v10.4.15`) with TypeScript (`v5.7.2`).
- **ORM & DB Engine**: Prisma ORM (`v5.22.0`) connected to **AWS RDS PostgreSQL**.
- **Cloud Storage**: AWS SDK v3 (`@aws-sdk/client-s3`, `@aws-sdk/s3-request-presigner`, `@aws-sdk/lib-storage`).
- **Security & Auth**: `@nestjs/passport`, `@nestjs/jwt`, `bcryptjs`, CORS middleware.
- **Documentation**: `@nestjs/swagger` (`v8.1.0`) live at `/api/docs`.
- **Optimization**: `compression` (Gzip/Brotli) & `ServeStaticModule` for Next.js bundle hosting.

### 🌐 C. Web Application (Next.js 16, React & Tailwind CSS)
- **Framework**: Next.js 16 App Router (`output: 'export'`).
- **Styling**: Tailwind CSS (`v4`), Vanilla Glassmorphism CSS, HSL gradients.
- **Icons**: `lucide-react` (`^0.475.0`).
- **Deployment**: Static production export generated in `backend/public/`.

---

## 3. 📂 Project Folder & Directory Structure

```text
MyVault/
├── android/                        # Android Native Project Config & Permissions
│   └── app/src/main/
│       └── AndroidManifest.xml     # Internet, Storage, Media & Notification Permissions
├── ios/                            # iOS Native Project Config
├── lib/                            # Flutter Mobile Application Source
│   ├── main.dart                   # Flutter App Entry Point
│   ├── app.dart                    # Root MaterialApp.router Shell
│   ├── core/
│   │   ├── config/                 # Environment Variables & Server URLs
│   │   ├── constants/              # AppColors (#07080D, #3E7BFF, #00D9F5), Typography
│   │   ├── router/
│   │   │   └── app_router.dart     # GoRouter Setup with Instant Auth Redirects
│   │   ├── services/               # CrashReporting, OfflineSync
│   │   └── storage/                # AppStorage (SharedPreferences & SecureStorage)
│   └── features/
│       ├── academic_hub/           # Semester Filter, Subject Cards & Material Downloads
│       │   ├── models/             # SubjectModel, AcademicContentModel
│       │   ├── presentation/       # AcademicHubScreen, SubjectDetailScreen
│       │   └── services/           # AcademicService (AWS S3 + Supabase Dual Engine)
│       └── auth/                   # Authentication Module
│           ├── application/        # AuthController (AsyncNotifier) & Providers
│           ├── data/               # AuthRepository, DioClient
│           └── presentation/       # SplashScreen, LoginScreen, RegistrationScreen
├── backend/                        # NestJS Production Backend
│   ├── Dockerfile                  # Alpine Linux Container with OpenSSL & Prisma Client
│   ├── aws-iam-policy.json         # AWS IAM Permissions Policy
│   ├── aws-s3-cors-policy.json     # AWS S3 Bucket CORS Policy
│   ├── aws-s3-bucket-policy.json   # AWS S3 Public Read Policy
│   ├── prisma/
│   │   └── schema.prisma           # AWS RDS PostgreSQL Database Models
│   ├── public/                     # Hosted Static Web App Export & Release APK
│   │   ├── index.html              # Next.js Web Landing Page
│   │   └── MyVault-release.apk     # 52.4MB Android Release APK
│   └── src/
│       ├── main.ts                 # Bootstrap, CORS, Compression & Swagger Configuration
│       ├── app.controller.ts       # Root /download-apk, /health & Static Hosting Handler
│       ├── app.module.ts           # Global NestJS Module Loader
│       ├── prisma/                 # PrismaService Database Pool
│       ├── storage/                # StorageService (AWS S3 Presigned URLs)
│       ├── academic/               # Academic Module (Subjects & Contents)
│       └── auth/                   # JWT Auth Controller & Services
├── frontend/                       # Next.js 16 Web Application Source
│   ├── src/
│   │   ├── app/
│   │   │   ├── page.tsx            # Home Landing Page (Hero, Mockup, Stats, Features)
│   │   │   ├── academic/page.tsx   # Web Academic Hub Filter
│   │   │   ├── placements/page.tsx # Campus Placement & Govt Jobs Portal
│   │   │   ├── upload/page.tsx     # Faculty AWS S3 Presigned Upload Dropzone
│   │   │   └── auth/               # Web Student Login & Registration
│   │   └── components/             # Navbar & Footer Glassmorphic Shell
│   └── next.config.ts              # Static Export Setup (output: 'export')
├── AWS_PERMISSIONS_GUIDE.md        # Comprehensive AWS Setup Manual
└── README.md                       # Project Documentation
```

---

## 4. 🗄️ Database Architecture (Prisma Schema / AWS RDS PostgreSQL)

```prisma
model Student {
  id               String   @id @default(uuid())
  hallTicketNumber String   @unique
  fullName         String   // Surname Firstname format
  email            String   @unique
  phone            String?
  courseType       String   @default("btech") // btech | degree
  branch           String
  semester         Int
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
  storagePath String?  // AWS S3 Bucket Key
  description String?
  createdAt   DateTime @default(now())
}
```

---

## 5. 🔌 Essential REST API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `GET /download-apk` | `GET` | Stream Android release APK (v1.2.0 - 52.4MB) directly from server disk |
| `GET /health` | `GET` | Server status check & uptime monitor |
| `POST /api/auth/register` | `POST` | Student registration with hall ticket & password |
| `POST /api/auth/login` | `POST` | Student login returning JWT Bearer token |
| `GET /api/academic/subjects` | `GET` | Fetch subjects filtered by branch, semester & type |
| `GET /api/academic/subjects/:id/contents` | `GET` | Fetch study materials for a specific subject |
| `GET /api/s3/presign-upload` | `GET` | Request 5-minute AWS S3 presigned PUT URL for direct browser/app upload |
| `POST /api/academic/contents` | `POST` | Register uploaded file metadata in RDS PostgreSQL |

---

## 🎨 6. UI/UX Design System & Theme Rules

1. **Color Palette**:
   - **Background**: `#07080D` (Ultra Dark Obsidian)
   - **Card Containers**: `rgba(255, 255, 255, 0.03)` with `backdrop-filter: blur(16px)` (Glassmorphism)
   - **Primary Accent**: `#3E7BFF` to `#00D9F5` (Electric Cyan Gradient)
   - **Text Primary**: `#FFFFFF` | **Text Secondary**: `#94A3B8`
2. **Typography**: Google Font **Inter** / **Poppins** with crisp line heights and generous tracking.
3. **Interactivity**: Micro-animations, subtle glow shadows on hover, smooth state transitions.

---

## 🚀 7. Step-by-Step Instructions to Build & Run Locally

### 1️⃣ Run NestJS Backend
```bash
cd backend
npm install --legacy-peer-deps
npx prisma generate
npm run start:dev
```

### 2️⃣ Run Next.js Frontend Website
```bash
cd frontend
npm install
npm run dev
```

### 3️⃣ Build & Export Web Production Bundle to Backend
```bash
cd frontend
npm run build
Copy-Item -Recurse -Force out\* ..\backend\public\
```

### 4️⃣ Build Mobile App Release APK
```bash
flutter build apk --release
```
The output APK will be generated at `build/app/outputs/flutter-apk/app-release.apk` (52.4 MB).
