-- =====================================================================
-- Govt Jobs — Schema
-- Supports posting new government job listings daily, across any sector,
-- auto-hides once the deadline passes, and links each listing to its
-- matching prep category in the Competitive Exams module (Apply + Prepare).
-- =====================================================================

-- First delete views if they exist to prevent type change conflicts
drop view if exists active_govt_jobs;
drop view if exists govt_jobs_posted_today;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'govt_job_sector') then
    create type govt_job_sector as enum (
      'banking', 'railways', 'defence', 'police', 'teaching',
      'central_civil_services', 'state_psc', 'psu_technical',
      'healthcare', 'judiciary', 'postal', 'insurance', 'other'
    );
  end if;
end$$;

create table if not exists govt_jobs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  organization text not null,
  sector govt_job_sector not null,
  location text,
  mode text not null default 'Online',           -- 'Online' | 'Walk-in'
  eligibility text,
  experience text default 'Fresher',
  vacancies int,
  salary text,
  apply_deadline date,                            -- null = rolling/no fixed deadline
  test_date date,
  apply_link text not null,                       -- official portal only
  prep_exam_id text references exams(id),         -- links to Competitive Exams module, nullable
  posted_date date not null default current_date, -- lets admin post a fresh batch daily
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_govt_jobs_sector on govt_jobs(sector);
create index if not exists idx_govt_jobs_posted_date on govt_jobs(posted_date desc);
create index if not exists idx_govt_jobs_deadline on govt_jobs(apply_deadline);

-- Students only ever see jobs that are still open — hides itself the day
-- after apply_deadline passes, no manual cleanup needed.
create or replace view active_govt_jobs as
select *
from govt_jobs
where is_active = true
  and (apply_deadline is null or apply_deadline >= current_date)
order by posted_date desc;

-- "New today" feed — for a Placement Desk / Govt Jobs home badge showing
-- what was added in the daily admin post.
create or replace view govt_jobs_posted_today as
select * from active_govt_jobs where posted_date = current_date;

alter table govt_jobs enable row level security;

-- Clean existing policies to avoid duplicates
drop policy if exists "govt_jobs readable when active" on govt_jobs;
drop policy if exists "admins manage govt_jobs" on govt_jobs;

create policy "govt_jobs readable when active"
  on govt_jobs for select using (
    is_active = true
  );

create policy "admins manage govt_jobs"
  on govt_jobs for all using (true);
