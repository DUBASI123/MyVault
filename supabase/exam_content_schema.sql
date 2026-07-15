-- =====================================================================
-- Competitive Exams — Content Schema
-- Adds: Recorded Videos, Study Material, Quiz, Mock Tests,
--       Previous Papers, Cheat Sheets — per exam, with rotation support
--       for Quiz (day-to-day) and Mock Tests (month-to-month).
-- =====================================================================

-- First delete views if they exist to prevent type change conflicts
drop view if exists today_quiz;
drop view if exists this_month_mock;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'exam_content_type') then
    create type exam_content_type as enum (
      'recorded_video',
      'study_material',
      'quiz',
      'mock_test',
      'previous_paper',
      'cheat_sheet'
    );
  end if;
end$$;

-- One row per exam category (GATE, GRE, CAT, Bank Exams, TSPSC, Placement Exams)
create table if not exists exams (
  id text primary key,               -- 'gate' | 'gre' | 'cat' | 'bank_exams' | 'tspsc' | 'placement_exams'
  name text not null,
  full_name text not null,
  description text,
  sort_order int not null default 0
);

-- All content items live here. Static items (videos, study material,
-- previous papers, cheat sheets) just have rotation_index = null.
-- Quiz items are tagged is_daily = true and rotate by rotation_index.
-- Mock test items are tagged is_monthly = true and rotate by rotation_index.
create table if not exists exam_content (
  id uuid primary key default gen_random_uuid(),
  exam_id text not null references exams(id) on delete cascade,
  content_type exam_content_type not null,
  title text not null,
  description text,
  topic text,                        -- e.g. 'Quantitative Aptitude', 'Telangana Movement'
  file_url text,                     -- Cloudinary/storage URL for video, PDF, etc.
  external_link text,                -- for previous_paper items pointing to official sources
  year int,                          -- for previous_paper items
  duration_seconds int,              -- for recorded_video items
  question_count int,                -- for quiz / mock_test items
  time_limit_minutes int,            -- for quiz / mock_test items
  rotation_index int,                -- 0-based order within the rotation cycle (quiz/mock only)
  is_daily boolean not null default false,   -- quiz items that rotate day-to-day
  is_monthly boolean not null default false, -- mock test items that rotate month-to-month
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_exam_content_exam_type on exam_content(exam_id, content_type);
create index if not exists idx_exam_content_rotation on exam_content(exam_id, content_type, rotation_index);

-- Tracks the fixed epoch each exam's rotation counts from, so "today's quiz"
-- and "this month's mock" are deterministic and never drift.
create table if not exists exam_rotation_config (
  exam_id text primary key references exams(id) on delete cascade,
  quiz_rotation_start date not null default '2026-07-01',   -- day 0 of the daily quiz cycle
  mock_rotation_start date not null default '2026-07-01'    -- month 0 of the monthly mock cycle
);

-- =====================================================================
-- RLS — students read published/active content only; admins (StuVault)
-- manage everything. Mirrors the pattern already used for the
-- Internships & Placements module.
-- =====================================================================
alter table exams enable row level security;
alter table exam_content enable row level security;
alter table exam_rotation_config enable row level security;

-- Clean existing policies to avoid duplicates
drop policy if exists "exams readable by all authenticated students" on exams;
drop policy if exists "exam_content readable when active" on exam_content;
drop policy if exists "exam_rotation_config readable by all authenticated students" on exam_rotation_config;
drop policy if exists "admins manage exams" on exams;
drop policy if exists "admins manage exam_content" on exam_content;
drop policy if exists "admins manage exam_rotation_config" on exam_rotation_config;

create policy "exams readable by all authenticated students"
  on exams for select using (true); -- changed to true/allow for simple public retrieval

create policy "exam_content readable when active"
  on exam_content for select using (
    is_active = true
  );

create policy "exam_rotation_config readable by all authenticated students"
  on exam_rotation_config for select using (true);

create policy "admins manage exams"
  on exams for all using (true);

create policy "admins manage exam_content"
  on exam_content for all using (true);

create policy "admins manage exam_rotation_config"
  on exam_rotation_config for all using (true);

-- =====================================================================
-- SQL helper views: "today's quiz" and "this month's mock test" per exam
-- rotation_index cycles using modulo, so the lists loop forever once
-- every quiz/mock in the set has been shown.
-- =====================================================================
create or replace view today_quiz as
select ec.*
from exam_content ec
join exam_rotation_config rc on rc.exam_id = ec.exam_id
where ec.content_type = 'quiz'
  and ec.is_daily = true
  and ec.is_active = true
  and ec.rotation_index = (
    (current_date - rc.quiz_rotation_start) %
    nullif((select count(*) from exam_content c2
            where c2.exam_id = ec.exam_id and c2.content_type = 'quiz' and c2.is_daily = true), 0)
  );

create or replace view this_month_mock as
select ec.*
from exam_content ec
join exam_rotation_config rc on rc.exam_id = ec.exam_id
where ec.content_type = 'mock_test'
  and ec.is_monthly = true
  and ec.is_active = true
  and ec.rotation_index = (
    ((extract(year from age(current_date, rc.mock_rotation_start)) * 12
      + extract(month from age(current_date, rc.mock_rotation_start)))::int) %
    nullif((select count(*) from exam_content c2
            where c2.exam_id = ec.exam_id and c2.content_type = 'mock_test' and c2.is_monthly = true), 0)
  );

insert into exams (id, name, full_name, description, sort_order) values
  ('gate', 'GATE', 'Graduate Aptitude Test in Engineering', 'For M.Tech/PhD admissions and PSU recruitment', 1),
  ('gre', 'GRE', 'Graduate Record Examination', 'For MS/PhD admissions abroad', 2),
  ('cat', 'CAT', 'Common Admission Test', 'For MBA admissions to IIMs and top B-schools', 3),
  ('bank_exams', 'Bank Exams', 'IBPS / SBI PO & Clerk', 'For Probationary Officer and Clerk recruitment', 4),
  ('tspsc', 'TSPSC', 'Telangana State Public Service Commission', 'For Telangana state government job recruitment', 5),
  ('placement_exams', 'Placement Exams', 'Company Aptitude & Recruitment Tests', 'TCS NQT, AMCAT, CoCubes and similar drives', 6)
on conflict (id) do nothing;

insert into exam_rotation_config (exam_id, quiz_rotation_start, mock_rotation_start)
select id, '2026-07-01', '2026-07-01' from exams
on conflict (exam_id) do nothing;
