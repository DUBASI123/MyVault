# 📋 MyVault — Complete Project Replication & Cloning Blueprint

This document is an step-by-step master guide to **replicating and building an exact clone of the MyVault project** from scratch in a new project directory.

---

## 🛠️ Phase 1: Environment & System Prerequisites

Before starting, install the following on your system:
1. **Flutter SDK**: `v3.19+` with Dart 3.x (`flutter doctor`).
2. **Node.js**: `v20.x LTS` and `npm v10.x`.
3. **Database**: AWS RDS PostgreSQL (or local PostgreSQL v15+).
4. **Cloud Storage**: AWS S3 Bucket (`ap-south-1`).
5. **Tools**: Git, VS Code or Android Studio.

---

## 🗄️ Phase 2: Database Schema & Prisma ORM Setup

### 1. Initialize Prisma in Backend Directory
```bash
mkdir backend
cd backend
npm init -y
npm install @prisma/client@5.22.0 prisma@5.22.0 --save-exact
npx prisma init
```

### 2. Copy `backend/prisma/schema.prisma`
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Student {
  id               String   @id @default(uuid())
  hallTicketNumber String   @unique @map("hall_ticket")
  fullName         String   @map("full_name")
  email            String   @unique
  courseType       String   @default("btech") @map("course_type")
  branch           String
  semester         Int      @default(1)
  passwordHash     String   @map("password_hash")
  createdAt        DateTime @default(now()) @map("created_at")
  @@map("students")
}

model Subject {
  id          String            @id @default(uuid())
  name        String
  code        String?
  branch      String
  semester    Int
  subjectType String            @default("academic") @map("subject_type")
  contents    AcademicContent[]
  @@unique([code, branch, semester])
  @@map("subjects")
}

model AcademicContent {
  id          String   @id @default(uuid())
  subjectId   String   @map("subject_id")
  title       String
  contentType String   @map("content_type")
  unitNumber  Int?     @map("unit_number")
  fileUrl     String?  @map("file_url")
  storagePath String?  @map("storage_path")
  description String?
  createdAt   DateTime @default(now()) @map("created_at")
  subject     Subject  @relation(fields: [subjectId], references: [id], onDelete: Cascade)
  @@map("academic_contents")
}
```

### 3. Generate Prisma Client
```bash
npx prisma db push
npx prisma generate
```

---

## ☁️ Phase 3: AWS S3 Object Storage Setup

### 1. Create S3 Bucket & CORS Policy
In AWS Console -> S3 -> Bucket Name: `myvault-study-materials` -> Permissions -> CORS:
```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
    "AllowedOrigins": ["*"],
    "ExposeHeaders": ["ETag", "Content-Length", "Content-Type"],
    "MaxAgeSeconds": 3600
  }
]
```

### 2. Implement AWS SDK Storage Service in Backend
Install AWS SDK:
```bash
npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner @aws-sdk/lib-storage
```

Create `backend/src/storage/storage.service.ts`:
```typescript
import { Injectable } from '@nestjs/common';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

@Injectable()
export class StorageService {
  private s3: S3Client;
  private bucket = process.env.AWS_BUCKET_NAME || 'myvault-study-materials';

  constructor() {
    this.s3 = new S3Client({
      region: process.env.AWS_REGION || 'ap-south-1',
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
      },
    });
  }

  async getPresignedUploadUrl(fileName: string, contentType: string, folder = 'study-materials') {
    const key = `${folder}/${Date.now()}_${fileName}`;
    const command = new PutObjectCommand({ Bucket: this.bucket, Key: key, ContentType: contentType });
    const uploadUrl = await getSignedUrl(this.s3, command, { expiresIn: 300 });
    return { uploadUrl, fileUrl: `https://${this.bucket}.s3.ap-south-1.amazonaws.com/${key}`, key };
  }
}
```

---

## ⚙️ Phase 4: NestJS Backend API Server

### 1. Install Backend Dependencies
```bash
npm install @nestjs/common @nestjs/core @nestjs/platform-express @nestjs/swagger @nestjs/jwt @nestjs/passport bcryptjs compression class-validator class-transformer reflect-metadata rxjs dotenv
```

### 2. Create `backend/src/main.ts`
```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as compression from 'compression';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(compression());
  app.enableCors({ origin: '*', methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS' });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const config = new DocumentBuilder()
    .setTitle('MyVault REST API')
    .setVersion('1.1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(process.env.PORT || 5000);
}
bootstrap();
```

---

## 🌐 Phase 5: Next.js 16 Web Application Setup

### 1. Initialize Frontend
```bash
npx -y create-next-app@latest frontend --ts --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm
```

### 2. Configure Next.js Static Export in `frontend/next.config.ts`
```typescript
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  output: 'export',
  images: { unoptimized: true },
};

export default nextConfig;
```

### 3. Build & Host Static Web Export in Backend
```bash
cd frontend
npm run build
Copy-Item -Recurse -Force out\* ..\backend\public\
```

---

## 📱 Phase 6: Flutter Mobile Application Setup

### 1. Initialize Flutter Project
```bash
flutter create myvault_app
cd myvault_app
```

### 2. Add `pubspec.yaml` Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0
  dio: ^5.4.3+1
  http: ^1.2.1
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.3
  supabase_flutter: ^2.8.4
  file_picker: ^8.0.0
  open_file: ^3.3.2
```

### 3. Implement Guarded GoRouter Navigation (`lib/core/router/app_router.dart`)
```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loggedIn = authState.value != null;
      final isLoading = authState.isLoading;
      final loc = state.matchedLocation;

      if (isLoading) return loc == '/splash' ? null : '/splash';
      if (!loggedIn) {
        if (loc == '/login' || loc == '/register' || loc == '/dev-settings') return null;
        return '/login';
      }
      if (loggedIn) {
        if (loc == '/splash' || loc == '/login' || loc == '/register') return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegistrationScreen()),
      GoRoute(path: '/home', builder: (_, __) => const AcademicHubScreen()),
    ],
  );
});
```

### 4. Build Release APK
```bash
flutter build apk --release
```

---

## 🚢 Phase 7: Docker & Cloud Deployment

### 1. Create `backend/Dockerfile`
```dockerfile
FROM node:20-alpine AS builder
RUN apk add --no-cache openssl libc6-compat
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npx prisma generate && npm run build

FROM node:20-alpine AS runner
RUN apk add --no-cache openssl libc6-compat
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm install --omit=dev --legacy-peer-deps
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

EXPOSE 5000
CMD ["node", "dist/main"]
```

### 2. Push to GitHub & Deploy to Render
- Repository: Push code to GitHub repository.
- Render: Connect repository -> Environment: Docker -> Set `DATABASE_URL`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_BUCKET_NAME`.

---

## 🎯 Verification Checklist

- [x] Backend responds at `GET /health` with `{ status: "online" }`.
- [x] Swagger docs live at `GET /api/docs`.
- [x] S3 presigned upload returns 5-min `uploadUrl` at `GET /api/s3/presign-upload`.
- [x] Release APK streams from `GET /download-apk`.
- [x] App navigates from `/splash` to `/login` in under **0.1 seconds**.
