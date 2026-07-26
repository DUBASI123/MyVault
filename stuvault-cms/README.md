# StuVault CMS

One platform, not two. This website and the MyVault app share the **same Supabase
project** (same database, same storage, same APIs). There's no upload UI in the app —
you upload/manage everything here, and it shows up in the app immediately (live via
Supabase Realtime).

```
MyVault app  ───┐
                 ├──►  same Supabase project (DB + Storage + Auth)
StuVault CMS ───┘        (this website writes, the app reads)
```

## What's included

- **Dashboard** — live counts across every content type
- **Study Materials** — recorded videos, notes, quizzes, mock tests, cheat sheets, previous papers
- **Courses** — LMS course content
- **Placements** — Placement Desk job listings
- **Govt Jobs** — government job listings by sector, linked to Competitive Exam folders
- **Notices** — short announcements, optional push notification flag
- Every section: drag-and-drop file upload straight to Supabase Storage, add/edit/delete, draft/published/expired status
- Admin login gated by a `cms_admins` table (only accounts you explicitly add can sign in)

## Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Connect to your existing MyVault Supabase project**
   ```bash
   cp .env.example .env
   ```
   Fill in `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` from your MyVault Supabase
   project settings (Project Settings → API). This is the **same project** MyVault
   already uses (`facqwktjfalukazexjye`) — don't create a new one.

3. **Run the schema migration**
   Open the Supabase SQL editor for that project and run `supabase/schema.sql`.
   It creates the CMS tables, RLS policies, and storage buckets. If you already
   have tables for some of this content under different names, skip those
   `CREATE TABLE` blocks and instead point the relevant page's `table` prop
   (in `src/pages/*.jsx`) at your existing table name.

4. **Create your admin login**
   In Supabase Auth, create a user (email + password) for yourself. Then in the
   SQL editor:
   ```sql
   insert into cms_admins (user_id, full_name, role)
   values ('<the-auth-user-uuid>', 'Your Name', 'super_admin');
   ```
   Find the UUID under Authentication → Users after creating the account.

5. **Run it**
   ```bash
   npm run dev
   ```

## How content reaches the app

Each table has a `status` column (`draft` / `published`). Row Level Security only
lets anonymous/app users read rows where `status = 'published'` — so the app's
Supabase queries just filter on `status = 'published'` the same way it already
does for other content, and drafts stay invisible until you publish them here.

## Adding a new content type later

1. Add a table + RLS policy pair to `supabase/schema.sql` (copy an existing block).
2. Add a storage bucket if it needs file uploads.
3. Create a page in `src/pages/` that renders `<ContentSection />` with your
   table name, bucket, form `fields`, and table `columns` — see
   `src/pages/Notices.jsx` for the shortest example.
4. Add it to the nav list in `src/components/Sidebar.jsx`.

No other plumbing needed — `ContentSection`, `useSupabaseTable`, and
`UploadDropzone` are all generic.
