-- ============================================================
-- supabase/internships_schema.sql
-- MyVault — Internships Module: Schema + Seed Data
-- ============================================================

-- ─── Tables ──────────────────────────────────────────────────

create table if not exists internship_courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  description text,
  thumbnail_url text,
  category text not null,
  difficulty text not null default 'beginner', -- beginner | intermediate | advanced
  duration_minutes int default 0,
  total_videos int default 0,
  total_assignments int default 0,
  instructor_name text,
  instructor_avatar text,
  rating numeric(2,1) default 0,
  enrolled_count int default 0,
  skills_you_learn text[] default '{}',
  is_approved boolean default true,
  created_by uuid,
  created_at timestamptz default now()
);

create table if not exists course_sections (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references internship_courses(id) on delete cascade,
  title text not null,
  order_index int default 0
);

create table if not exists course_videos (
  id uuid primary key default gen_random_uuid(),
  section_id uuid references course_sections(id) on delete cascade,
  course_id uuid references internship_courses(id) on delete cascade,
  title text not null,
  description text,
  video_url text not null,        -- Cloudinary video URL
  thumbnail_url text,
  duration_seconds int default 0,
  order_index int default 0,
  is_preview boolean default false,
  resources text[] default '{}'
);

create table if not exists course_assignments (
  id uuid primary key default gen_random_uuid(),
  section_id uuid references course_sections(id) on delete cascade,
  course_id uuid references internship_courses(id) on delete cascade,
  title text not null,
  description text,
  instructions text,
  max_score int default 100,
  order_index int default 0,
  due_date timestamptz,
  attachment_urls text[] default '{}'
);

create table if not exists course_test_questions (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references internship_courses(id) on delete cascade,
  question text not null,
  options text[] not null,
  correct_option_index int not null,
  explanation text,
  marks int default 1,
  order_index int default 0
);

create table if not exists student_course_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid,
  course_id uuid references internship_courses(id) on delete cascade,
  completed_video_ids uuid[] default '{}',
  submitted_assignment_ids uuid[] default '{}',
  status text default 'not_started', -- not_started | in_progress | completed | certified
  test_score int,
  test_max_score int,
  test_passed boolean default false,
  test_attempts int default 0,
  certificate_id uuid,
  enrolled_at timestamptz default now(),
  completed_at timestamptz,
  certified_at timestamptz,
  unique(student_id, course_id)
);

create table if not exists assignment_submissions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid,
  assignment_id uuid references course_assignments(id) on delete cascade,
  course_id uuid references internship_courses(id) on delete cascade,
  submission_text text,
  attachment_urls text[] default '{}',
  score int,
  feedback text,
  is_graded boolean default false,
  submitted_at timestamptz default now(),
  graded_at timestamptz
);

create table if not exists course_certificates (
  id uuid primary key default gen_random_uuid(),
  student_id uuid,
  student_name text not null,
  hall_ticket_no text not null,
  course_id uuid references internship_courses(id) on delete cascade,
  course_title text not null,
  college_id uuid,
  test_score int not null,
  test_max_score int not null,
  issued_at timestamptz default now(),
  verification_code text unique not null,
  pdf_url text
);

create table if not exists internship_opportunities (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  company_logo_url text,
  role text not null,
  description text,
  type text default 'internship', -- internship | job | freelance
  location text,
  is_remote boolean default false,
  duration text,
  stipend text default 'Unpaid',
  required_skills text[] default '{}',
  preferred_course_ids uuid[] default '{}',
  posted_at timestamptz default now(),
  deadline timestamptz not null,
  apply_url text not null,
  is_approved boolean default false,
  related_course_id uuid references internship_courses(id),
  posted_by uuid
);

-- ─── Indexes ─────────────────────────────────────────────────
create index if not exists idx_progress_student on student_course_progress(student_id);
create index if not exists idx_videos_section on course_videos(section_id, order_index);
create index if not exists idx_assignments_section on course_assignments(section_id, order_index);
create index if not exists idx_opportunities_deadline on internship_opportunities(deadline) where is_approved = true;

-- ─── RLS ─────────────────────────────────────────────────────
alter table internship_courses enable row level security;
alter table course_sections enable row level security;
alter table course_videos enable row level security;
alter table course_assignments enable row level security;
alter table course_test_questions enable row level security;
alter table student_course_progress enable row level security;
alter table assignment_submissions enable row level security;
alter table course_certificates enable row level security;
alter table internship_opportunities enable row level security;

drop policy if exists courses_read_all on internship_courses;
create policy "courses_read_all" on internship_courses for select using (is_approved = true);

drop policy if exists sections_read_all on course_sections;
create policy "sections_read_all" on course_sections for select using (true);

drop policy if exists videos_read_all on course_videos;
create policy "videos_read_all" on course_videos for select using (true);

drop policy if exists assignments_read_all on course_assignments;
create policy "assignments_read_all" on course_assignments for select using (true);

drop policy if exists progress_own on student_course_progress;
create policy "progress_own" on student_course_progress
  for all using (auth.uid() = student_id) with check (auth.uid() = student_id);

drop policy if exists submissions_own on assignment_submissions;
create policy "submissions_own" on assignment_submissions
  for all using (auth.uid() = student_id) with check (auth.uid() = student_id);

drop policy if exists certificates_own_read on course_certificates;
create policy "certificates_own_read" on course_certificates
  for select using (auth.uid() = student_id);

drop policy if exists opportunities_read_approved on internship_opportunities;
create policy "opportunities_read_approved" on internship_opportunities
  for select using (is_approved = true);

-- ─── RPC: start test without exposing correct answers ─────────
create or replace function get_course_test(p_course_id uuid)
returns table(id uuid, question text, options text[], marks int)
language sql security definer as $$
  select id, question, options, marks
  from course_test_questions
  where course_id = p_course_id
  order by order_index;
$$;

-- ─── RPC: submit test, auto-grade, update progress, issue cert ─
create or replace function submit_course_test(
  p_course_id uuid,
  p_answers jsonb -- [{"question_id": "...", "selected_index": 2}, ...]
) returns jsonb
language plpgsql security definer as $$
declare
  v_student uuid := auth.uid();
  v_total_marks int := 0;
  v_scored_marks int := 0;
  v_q record;
  v_ans jsonb;
  v_passed boolean;
  v_cert_id uuid;
  v_student_name text;
  v_hall_ticket text;
  v_college_id uuid;
  v_course_title text;
  v_verification text;
begin
  for v_q in select * from course_test_questions where course_id = p_course_id loop
    v_total_marks := v_total_marks + v_q.marks;
    v_ans := (select a from jsonb_array_elements(p_answers) a
              where (a->>'question_id')::uuid = v_q.id limit 1);
    if v_ans is not null and (v_ans->>'selected_index')::int = v_q.correct_option_index then
      v_scored_marks := v_scored_marks + v_q.marks;
    end if;
  end loop;

  v_passed := (v_scored_marks::numeric / nullif(v_total_marks,0)) >= 0.6; -- 60% pass mark

  update student_course_progress
  set test_score = v_scored_marks,
      test_max_score = v_total_marks,
      test_passed = v_passed,
      test_attempts = test_attempts + 1,
      status = case when v_passed then 'certified' else status end,
      completed_at = coalesce(completed_at, now()),
      certified_at = case when v_passed then now() else certified_at end
  where student_id = v_student and course_id = p_course_id;

  if v_passed then
    select first_name || ' ' || last_name, hall_ticket, college_id into v_student_name, v_hall_ticket, v_college_id
    from students where id = v_student;

    select title into v_course_title from internship_courses where id = p_course_id;
    v_verification := upper(substr(md5(random()::text || v_student::text), 1, 10));

    insert into course_certificates(
      student_id, student_name, hall_ticket_no, course_id, course_title,
      college_id, test_score, test_max_score, verification_code
    ) values (
      v_student, coalesce(v_student_name,'Student'), coalesce(v_hall_ticket,''),
      p_course_id, v_course_title, v_college_id, v_scored_marks, v_total_marks, v_verification
    ) returning id into v_cert_id;

    update student_course_progress set certificate_id = v_cert_id
    where student_id = v_student and course_id = p_course_id;
  end if;

  return jsonb_build_object(
    'score', v_scored_marks,
    'max_score', v_total_marks,
    'passed', v_passed,
    'certificate_id', v_cert_id
  );
end;
$$;

-- ============================================================
-- SEED DATA — sample internship-prep courses
-- ============================================================

-- Courses insertion (use on conflict/check exists to avoid duplicate seed issues)
insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '11111111-1111-1111-1111-111111111111',
  'Full-Stack Web Development Internship Prep',
  'Build real projects with React & Node.js',
  'A hands-on internship-readiness course covering frontend, backend, REST APIs, and deployment — designed to get you internship-ready in 4 weeks.',
  'https://res.cloudinary.com/demo/image/upload/v1/courses/webdev_thumb.jpg',
  'Web Development', 'beginner', 480, 12, 3,
  'Priya Sharma', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/priya.jpg',
  4.7, 1280,
  array['React.js','Node.js','REST APIs','Git & GitHub','Deployment'],
  true
) on conflict (id) do nothing;

insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '22222222-2222-2222-2222-222222222222',
  'Data Analytics Internship Track',
  'Python, Pandas & real datasets',
  'Learn data cleaning, visualization, and analysis using Python and Pandas with real-world internship-style datasets and case studies.',
  'https://res.cloudinary.com/demo/image/upload/v1/courses/data_thumb.jpg',
  'Data Science', 'intermediate', 360, 10, 3,
  'Arjun Reddy', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/arjun.jpg',
  4.6, 945,
  array['Python','Pandas','Data Visualization','SQL','Excel'],
  true
) on conflict (id) do nothing;

insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '33333333-3333-3333-3333-333333333333',
  'UI/UX Design Internship Bootcamp',
  'Figma to portfolio-ready case studies',
  'Master design thinking, wireframing, and prototyping in Figma while building a portfolio piece that internship recruiters look for.',
  'https://res.cloudinary.com/demo/image/upload/v1/courses/uiux_thumb.jpg',
  'UI/UX Design', 'beginner', 300, 8, 2,
  'Sneha Iyer', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/sneha.jpg',
  4.8, 730,
  array['Figma','Wireframing','Prototyping','User Research'],
  true
) on conflict (id) do nothing;

insert into internship_courses
  (id, title, subtitle, description, thumbnail_url, category, difficulty,
   duration_minutes, total_videos, total_assignments, instructor_name,
   instructor_avatar, rating, enrolled_count, skills_you_learn, is_approved)
values (
  '44444444-4444-4444-4444-444444444444',
  'Android App Development with Flutter',
  'Ship your first cross-platform app',
  'Go from zero to a published Flutter app — widgets, state management, APIs, and Play Store submission, all internship-portfolio ready.',
  'https://res.cloudinary.com/demo/image/upload/v1/courses/flutter_thumb.jpg',
  'Mobile Development', 'intermediate', 420, 11, 3,
  'Kiran Kumar', 'https://res.cloudinary.com/demo/image/upload/v1/avatars/kiran.jpg',
  4.5, 612,
  array['Flutter','Dart','Riverpod','REST APIs','Play Store Deployment'],
  true
) on conflict (id) do nothing;


-- Sections + Videos + Assignment for Course 1 (Full-Stack Web Dev)
insert into course_sections (id, course_id, title, order_index) values
  ('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'Week 1: Frontend Foundations', 1),
  ('66666666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', 'Week 2: Backend & APIs', 2),
  ('77777777-7777-7777-7777-777777777777', '11111111-1111-1111-1111-111111111111', 'Week 3: Full-Stack Integration & Deployment', 3)
  on conflict (id) do nothing;

insert into course_sections (id, course_id, title, order_index) values
  ('88888888-8888-8888-8888-888888888888', '22222222-2222-2222-2222-222222222222', 'Python & Data Cleaning Basics', 1),
  ('99999999-9999-9999-9999-999999999999', '22222222-2222-2222-2222-222222222222', 'Visualization & Case Studies', 2)
  on conflict (id) do nothing;

insert into course_sections (id, course_id, title, order_index) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'Design Fundamentals & Wireframing', 1),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 'Prototyping & Portfolio Case Study', 2)
  on conflict (id) do nothing;

insert into course_sections (id, course_id, title, order_index) values
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '44444444-4444-4444-4444-444444444444', 'Flutter Basics & Widgets', 1),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '44444444-4444-4444-4444-444444444444', 'State, APIs & Publishing', 2)
  on conflict (id) do nothing;


-- ─── Sample Videos for Course 1 / Section "Week 1" ─────────────
insert into course_videos (id, section_id, course_id, title, description, video_url, duration_seconds, order_index, is_preview) values
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111',
   'Intro: What Recruiters Look For', 'Overview of the internship hiring process and what skills matter most.',
   'https://res.cloudinary.com/demo/video/upload/v1/courses/webdev_intro.mp4', 600, 1, true),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111',
   'HTML, CSS & Responsive Layouts', 'Build a responsive landing page from scratch.',
   'https://res.cloudinary.com/demo/video/upload/v1/courses/webdev_html_css.mp4', 1500, 2, false),
  ('00000000-0000-0000-0000-000000000000', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111',
   'React Components & Props', 'Componentizing your UI the React way.',
   'https://res.cloudinary.com/demo/video/upload/v1/courses/webdev_react_components.mp4', 1800, 3, false)
  on conflict (id) do nothing;


-- ─── Sample Assignment for Course 1 ─────────────────────────────
insert into course_assignments (id, section_id, course_id, title, description, instructions, max_score, order_index) values
  ('12345678-1234-1234-1234-123456789012', '55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111',
   'Build a Responsive Landing Page',
   'Apply HTML/CSS skills to design a landing page for a fictional startup.',
   'Submit a link to your code or describe your work briefly.',
   100, 1)
  on conflict (id) do nothing;


-- ─── Sample Test Questions for Course 1 ─────────────────────────
insert into course_test_questions (id, course_id, question, options, correct_option_index, marks, order_index) values
  ('34567890-3456-3456-3456-345678901234', '11111111-1111-1111-1111-111111111111',
   'Which HTML tag is used to define a navigation section?',
   array['<nav>','<section>','<div>','<menu>'], 0, 10, 1),
  ('45678901-4567-4567-4567-456789012345', '11111111-1111-1111-1111-111111111111',
   'Which hook is used to manage state in a React functional component?',
   array['useEffect','useState','useRef','useMemo'], 1, 10, 2),
  ('56789012-5678-5678-5678-567890123456', '11111111-1111-1111-1111-111111111111',
   'What does REST stand for?',
   array['Remote State Transfer','Representational State Transfer','Real-time State Transfer','Resource State Transfer'], 1, 10, 3)
  on conflict (id) do nothing;


-- ============================================================
-- SEED DATA — sample internship opportunities
-- ============================================================
insert into internship_opportunities
  (id, company_name, company_logo_url, role, description, type, location, is_remote,
   duration, stipend, required_skills, posted_at, deadline, apply_url, is_approved)
values
  ('9a8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d', 'TechNova Solutions', 'https://res.cloudinary.com/demo/image/upload/v1/companies/technova.png',
   'Frontend Developer Intern', 'Work on real client dashboards using React.js under senior mentorship.',
   'internship', 'Hyderabad', false, '3 months', '₹12,000/month',
   array['React.js','JavaScript','Git'], now(), now() + interval '30 days',
   'https://technova.example.com/careers/frontend-intern', true),

  ('8a7b6c5d-4e3f-2a1b-0c9d-8e7f6a5b4c3d', 'DataPulse Analytics', 'https://res.cloudinary.com/demo/image/upload/v1/companies/datapulse.png',
   'Data Analyst Intern', 'Analyze real business datasets and build dashboards for client reporting.',
   'internship', 'Remote', true, '2 months', '₹8,000/month',
   array['Python','Pandas','SQL'], now(), now() + interval '21 days',
   'https://datapulse.example.com/careers/data-intern', true),

  ('7a6b5c4d-3e2f-1a0b-9c8d-7e6f5a4b3c2d', 'PixelCraft Studio', 'https://res.cloudinary.com/demo/image/upload/v1/companies/pixelcraft.png',
   'UI/UX Design Intern', 'Design app interfaces for early-stage startups; portfolio-building opportunity.',
   'internship', 'Bengaluru', true, '3 months', 'Unpaid (Certificate + LOR)',
   array['Figma','Wireframing'], now(), now() + interval '45 days',
   'https://pixelcraft.example.com/careers/uiux-intern', true),

  ('6a5b4c3d-2e1f-0a9b-8c7d-6e5f4a3b2c1d', 'AppForge Labs', 'https://res.cloudinary.com/demo/image/upload/v1/companies/appforge.png',
   'Flutter Developer Intern', 'Contribute to a live Flutter app used by 50,000+ students.',
   'internship', 'Hyderabad', true, '4 months', '₹15,000/month',
   array['Flutter','Dart','REST APIs'], now(), now() + interval '60 days',
   'https://appforge.example.com/careers/flutter-intern', true)
  on conflict (id) do nothing;
