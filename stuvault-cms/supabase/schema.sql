-- StuVault CMS Database & Storage Setup
-- Copy and run this script in your Supabase SQL Editor: https://supabase.com/dashboard

-- 1. Create User Uploads Table (Shared across Website & Flutter App)
create table if not exists files (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  file_url text not null,
  file_name text not null,
  created_at timestamp with time zone default now()
);

alter table files enable row level security;

-- Policies for files table
drop policy if exists "Users can insert own files" on files;
drop policy if exists "Users can view own files" on files;
drop policy if exists "Users can delete own files" on files;
drop policy if exists "Allow public access files" on files;

create policy "Allow public access files" on files for all using (true) with check (true);

-- 2. Create Mobile & CMS Tables
create table if not exists subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text,
  branch text,
  semester integer default 1,
  subject_type text default 'academic',
  created_at timestamptz not null default now()
);

create table if not exists academic_contents (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references subjects(id) on delete cascade,
  title text not null,
  content_type text not null,
  description text,
  unit_number integer,
  file_url text,
  storage_path text,
  created_at timestamptz not null default now()
);

create table if not exists placement_jobs (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  role text not null,
  job_type text default 'fullTime',
  work_mode text default 'onsite',
  location text,
  salary_range text,
  apply_url text not null,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists govt_jobs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  organization text not null,
  sector text not null,
  location text,
  eligibility text,
  vacancies integer,
  apply_deadline date,
  apply_link text not null,
  created_at timestamptz not null default now()
);

create table if not exists courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  instructor text,
  description text,
  duration_hours numeric,
  status text not null default 'published',
  created_at timestamptz not null default now()
);

create table if not exists notices (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  audience text default 'All students',
  push_notification text default 'No',
  status text not null default 'published',
  created_at timestamptz not null default now()
);

-- 3. Row Level Security Policies
alter table subjects enable row level security;
alter table academic_contents enable row level security;
alter table placement_jobs enable row level security;
alter table govt_jobs enable row level security;
alter table courses enable row level security;
alter table notices enable row level security;

create policy "Public access subjects" on subjects for all using (true) with check (true);
create policy "Public access academic_contents" on academic_contents for all using (true) with check (true);
create policy "Public access placement_jobs" on placement_jobs for all using (true) with check (true);
create policy "Public access govt_jobs" on govt_jobs for all using (true) with check (true);
create policy "Public access courses" on courses for all using (true) with check (true);
create policy "Public access notices" on notices for all using (true) with check (true);

-- 4. Create Storage Buckets
insert into storage.buckets (id, name, public)
values
  ('website-uploads', 'website-uploads', true),
  ('study-materials', 'study-materials', true),
  ('course-content', 'course-content', true),
  ('notices', 'notices', true),
  ('job-attachments', 'job-attachments', true)
on conflict (id) do update set public = true;

drop policy if exists "Public read bucket objects" on storage.objects;
drop policy if exists "Public write bucket objects" on storage.objects;
drop policy if exists "Public delete bucket objects" on storage.objects;

create policy "Public read bucket objects" on storage.objects for select using (true);
create policy "Public write bucket objects" on storage.objects for insert with check (true);
create policy "Public delete bucket objects" on storage.objects for delete using (true);
