-- ─── Placements / Jobs ────────────────────────────────────────

create table if not exists placement_jobs (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  company_logo_url text,
  role text not null,
  description text,
  job_type text not null default 'fullTime',       -- internship | fullTime | partTime | freelance | contract
  work_mode text not null default 'onsite',         -- onsite | remote | hybrid
  experience_level text not null default 'fresher', -- fresher | junior | mid | senior | lead
  location text,
  salary_range text,
  qualification text,
  experience text,
  shift text,
  contact_info text,
  posted_by text,
  department text,
  skills text[] default '{}',
  tags text[] default '{}',
  apply_url text not null default '',
  posted_at timestamptz not null default now(),
  deadline timestamptz,
  is_urgent boolean not null default false,
  is_featured boolean not null default false,
  is_approved boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists student_saved_jobs (
  id uuid primary key default gen_random_uuid(),
  student_id text not null references students(id) on delete cascade,
  job_id uuid not null references placement_jobs(id) on delete cascade,
  saved_at timestamptz not null default now(),
  unique(student_id, job_id)
);

create index if not exists idx_placement_jobs_type on placement_jobs(job_type);
create index if not exists idx_placement_jobs_mode on placement_jobs(work_mode);
create index if not exists idx_placement_jobs_level on placement_jobs(experience_level);
create index if not exists idx_placement_jobs_featured on placement_jobs(is_featured, is_urgent, posted_at desc);
create index if not exists idx_saved_jobs_student on student_saved_jobs(student_id);

alter table placement_jobs enable row level security;
alter table student_saved_jobs enable row level security;

drop policy if exists placement_jobs_read_approved on placement_jobs;
create policy "placement_jobs_read_approved" on placement_jobs
  for select using (is_approved = true);

drop policy if exists saved_jobs_own on student_saved_jobs;
create policy "saved_jobs_own" on student_saved_jobs
  for all using (auth.uid()::text = student_id::text);

-- ─── Seed: Sample Placement Jobs ─────────────────────────────

insert into placement_jobs
  (id, company_name, company_logo_url, role, description, job_type, work_mode,
   experience_level, location, salary_range, skills, tags, apply_url,
   is_urgent, is_featured)
values
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890',
   'TechCorp India', '', 'Software Engineer Trainee',
   'Join our graduate program and build scalable backend services using Node.js and cloud infrastructure.',
   'fullTime', 'hybrid', 'fresher', 'Hyderabad',
   '4-6 LPA', array['Node.js','SQL','REST APIs'], array['tech','graduate','2024'],
   'https://techcorp.example.com/careers/set', false, true),

  ('b2c3d4e5-f6a7-8901-bcde-f12345678901',
   'StartupLaunch', '', 'Full Stack Developer',
   'Work directly with the founding team on a B2B SaaS product. React + FastAPI stack.',
   'fullTime', 'remote', 'junior', 'Remote',
   '6-10 LPA', array['React','Python','FastAPI','PostgreSQL'], array['startup','remote','saas'],
   'https://startupx.example.com/careers', true, false),

  ('c3d4e5f6-a7b8-9012-cdef-123456789012',
   'DesignStudio Co', '', 'UI/UX Designer',
   'Craft beautiful user interfaces for our suite of consumer apps. Portfolio required.',
   'fullTime', 'onsite', 'junior', 'Bengaluru',
   '5-8 LPA', array['Figma','Prototyping','User Research'], array['design','ui','ux'],
   'https://designstudio.example.com/jobs', false, true),

  ('d4e5f6a7-b8c9-0123-def0-234567890123',
   'DataMinds Analytics', '', 'Data Analyst Intern',
   '6-month paid internship working with large datasets using Python, SQL and Power BI.',
   'internship', 'hybrid', 'fresher', 'Chennai',
   '12000/month', array['Python','SQL','Power BI','Excel'], array['data','internship','analytics'],
   'https://dataminds.example.com/intern', true, false)
  on conflict (id) do nothing;
