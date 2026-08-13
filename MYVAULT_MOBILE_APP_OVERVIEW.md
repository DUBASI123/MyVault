# 📱 MyVault Mobile App — Complete Feature, Tech & Architecture Overview

This document details everything about the **MyVault Flutter Mobile Application**: how it looks, how it functions, the technology stack used, and the full inventory of built-in features.

---

## 🎨 1. App Design & Visual User Flow

```text
 ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
 │   Splash Screen  │ ───► │   Login / Reg    │ ───► │  Home Dashboard  │
 │  (#07080D Theme) │      │ (Hall Ticket/Pw) │      │  (Notice Ticker) │
 └──────────────────┘      └──────────────────┘      └─────────┬────────┘
                                                               │
                           ┌───────────────────────────────────┴───────────────────────────────────┐
                           ▼                                                                       ▼
             ┌───────────────────────────┐                                           ┌───────────────────────────┐
             │    Academic Study Hub     │                                           │   Placements & Job Hub    │
             │ (Branch/Sem/Subject/Notes)│                                           │ (IT/Core/Govt Drives/PDFs)│
             └───────────────────────────┘                                           └───────────────────────────┘
```

### 🌟 UI/UX Aesthetics
- **Theme**: Ultra Dark Obsidian (`#07080D`) with glassmorphism panels (`backdrop-filter: blur(16px)`).
- **Gradients**: Electric Cyan (`#3E7BFF` to `#00D9F5`).
- **Typography**: Google Font **Poppins** and **Inter**.

---

## 🛠️ 2. Technology Stack & Packages Used

| Component / Layer | Technology | Package Version | Purpose |
|---|---|---|---|
| **Framework** | Flutter / Dart | `Flutter ^3.19.0` | Cross-platform native mobile compilation |
| **State Management** | Riverpod | `flutter_riverpod ^2.5.1` | Decoupled AsyncNotifier state management |
| **Navigation** | GoRouter | `go_router ^13.2.0` | Declarative guarded routes & instant redirects |
| **HTTP Networking** | Dio & Http | `dio ^5.4.3+1`, `http ^1.2.1` | AWS REST API calls & presigned S3 uploads |
| **Secure Token Storage**| Secure Storage | `flutter_secure_storage ^9.0.0` | Encrypted JWT token persistence on device |
| **App Settings** | SharedPreferences | `shared_preferences ^2.2.3` | Persistent local app settings & custom backend URLs |
| **Dual Engine Client** | Supabase | `supabase_flutter ^2.8.4` | Direct fallback database & storage engine |
| **File Management** | File Picker & Open | `file_picker ^8.0.0`, `open_file ^3.3.2` | Native PDF/Doc viewing & downloading |

---

## 🚀 3. Complete Feature Inventory Inside The App

### 1. 🔐 Auth & Security Module
- **⚡ Instant Splash Screen (`/splash`)**: Features a fade-in animation and non-blocking GoRouter state evaluation that routes unauthenticated users to `/login` in under **0.1s**.
- **🔑 Student Login (`/login`)**: Input Hall Ticket Number and Password with validation against NestJS JWT auth.
- **📝 Student Registration (`/register`)**:
  - **Course Type Toggle**: B.Tech vs Degree course selection.
  - **Surname Firstname Formatter**: Automatically formats student names as `"Lastname Firstname"`.
  - **Auto Password Generator**: Sets default password to Hall Ticket Number.
- **🛠️ Hidden Developer Settings Modal (`/dev-settings`)**: Double-clicking the logo on the login page opens a developer drawer to override the backend API base URL on the fly.

### 2. 📢 Live Notice Ticker & Home Dashboard
- **Live Ticker Bar**: Top scrolling announcement bar fetching college circulars live from NestJS backend (`GET /api/content/ticker`).
- **Quick Action Tiles**: Fast access to Academic Hub, Results, Placements, and Study Planner.

### 3. 📚 Academic Study Hub
- **Branch Filter**: ECE, CSE, CSE (AI & ML), EEE, MECH, CIVIL, GENERAL.
- **Semester Selector**: 1st Year (Sem 1, Sem 2) through 4th Year (Sem 7, Sem 8).
- **Subject Cards**: Displays subject code (e.g. `MA101BS`, `AP102BS`), subject title, and material count.
- **Material Categories**:
  - 📄 **Notes** (PDF)
  - 🎬 **Video Lectures** (MP4)
  - 🧪 **Lab Manuals**
  - ⚡ **Cheat Sheets**
  - 📋 **Assignments**
  - 📊 **Previous Question Papers**
- **Unit Number Tags**: Unit 1 through Unit 5 organization.

### 4. ⚡ Dual-Engine Cloud Architecture & Sub-100ms Speed
- **Primary Cloud**: Queries NestJS REST API connected to **AWS RDS PostgreSQL** and presigned **AWS S3** URLs.
- **Instant Fallback**: If AWS is cold-starting, automatically queries **Supabase Database** (`subjects`, `academic_contents`) and **Supabase Storage** (`academic-files` bucket).
- **Offline Mock Seed**: Instant `< 100 ms` offline subject fallback so screens render immediately regardless of network conditions.

### 5. 🤖 Native Android Integration
- **Full Android 13+ Permissions (`AndroidManifest.xml`)**:
  - `android.permission.INTERNET`
  - `android.permission.ACCESS_NETWORK_STATE`
  - `android.permission.READ_EXTERNAL_STORAGE` & `WRITE_EXTERNAL_STORAGE`
  - `android.permission.READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`
  - `android.permission.POST_NOTIFICATIONS`

---

## 📥 4. App Download & File Paths

- **Live Server APK Download**: [https://myvault-f08x.onrender.com/download-apk](https://myvault-f08x.onrender.com/download-apk)
- **Local APK Path**: `build/app/outputs/flutter-apk/app-release.apk` (52.4 MB)
- **GitHub Repository**: [https://github.com/DUBASI123/MyVault](https://github.com/DUBASI123/MyVault)
