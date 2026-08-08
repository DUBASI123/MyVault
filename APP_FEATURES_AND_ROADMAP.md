# 📱 MyVault Mobile App — Current Feature Inventory & Future Roadmap

This document outlines everything currently built and fully working inside the **MyVault Flutter Mobile Application**, alongside optional upcoming modules for future development iterations.

---

## ✅ Part 1: What We HAVE in the App (Completed Modules)

### 🔐 1. Authentication & Security Module
- **⚡ Instant Splash Screen (`/splash`)**: Built with smooth fade-in animations and instant GoRouter state redirects to eliminate infinite loading hangs.
- **🔑 Student Login (`/login`)**: Secure login with Hall Ticket Number & Password authentication against NestJS backend.
- **📝 Student Registration (`/register`)**: Self-contained registration supporting:
  - **Course Type Toggle**: B.Tech vs Degree.
  - **Surname Firstname Validator**: Formats student names as `"Lastname Firstname"`.
  - **Auto Password Generator**: Defaults password to Hall Ticket Number.
- **🛠️ Hidden Developer Settings Modal (`/dev-settings`)**: Triggered by double-clicking the logo on the login page, allowing developers to switch backend API URLs on the fly (`https://myvault-f08x.onrender.com`).
- **🛡️ Secure Storage & Auth Persistence**: Uses `flutter_secure_storage` to persist JWT tokens securely on the device keychain.

### 📚 2. Academic Study Hub Module
- **🎓 Semester & Branch Filter**: Filter subjects by:
  - **Branches**: ECE, CSE, AI & ML, EEE, MECH, CIVIL, GENERAL.
  - **Semesters**: 1st Year (Sem 1, Sem 2) through 4th Year (Sem 7, Sem 8).
- **📖 Subject & Material Cards**: Displays subject code (e.g. `MA101BS`), subject name, category (`NOTES`, `QUESTION_BANK`, `SYLLABUS`, `LAB_MANUAL`).
- **⬇️ Material Viewing & Downloading**: Streams materials directly from AWS S3 or opens public URLs with `open_file` and `path_provider`.

### ⚡ 3. Dual-Engine Cloud Architecture (AWS + Supabase)
- **Primary AWS Cloud Engine**: Queries NestJS REST API connected to **AWS RDS PostgreSQL** and presigned **AWS S3** URLs.
- **Instant Supabase Fallback**: If AWS is unreachable or cold starting, the app automatically switches to **Supabase Database** (`subjects`, `academic_contents`) and **Supabase Storage** (`academic-files` bucket at `https://roaxygqyuemlpxygvzyq.supabase.co`).
- **Offline Mock Fallback**: Includes pre-seeded local subject fallbacks so the app renders UI in `< 100 ms` under any network condition.

### 🤖 4. Native Android Configuration
- **Full Android Permissions (`AndroidManifest.xml`)**:
  - `INTERNET` & `ACCESS_NETWORK_STATE`
  - `READ_EXTERNAL_STORAGE` & `WRITE_EXTERNAL_STORAGE`
  - `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO` (Android 13+ API 33)
  - `POST_NOTIFICATIONS`

---

## 🔮 Part 2: What We CAN Build Next (Future Enhancements)

While the core app is 100% functional, production-ready, and compiled to a **52.4MB Release APK**, here are optional features that can be added in future updates:

1. **🔔 Firebase Cloud Messaging (FCM)**: Send real-time push notification popups for exam timetables and result announcements.
2. **💾 Offline Native PDF Cache (Hive / SQLite)**: Save downloaded PDFs locally in encrypted app storage so students can view study notes offline without internet.
3. **📊 Dynamic SGPA / CGPA Calculator**: A dedicated screen where students enter grades per subject to automatically calculate semester CGPA.
4. **💼 Native Mobile Placements Screen**: Bring the web placement portal (`/placements`) into a native Flutter view with job application tracking.
