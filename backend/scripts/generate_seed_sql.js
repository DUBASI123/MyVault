import fs from 'fs';
import path from 'path';

function formatCollegeUuid(idStr) {
  const num = parseInt(idStr.replace('c_', ''), 10);
  const hex = (num + 256).toString(16).padStart(12, '0');
  return `00000000-0000-0000-0000-${hex}`;
}

function formatUniUuid(idStr) {
  const num = parseInt(idStr, 10);
  const hex = num.toString(16).padStart(12, '0');
  return `00000000-0000-0000-0000-${hex}`;
}

async function main() {
  const collegesPath = path.resolve('prisma/colleges.json');
  const colleges = JSON.parse(fs.readFileSync(collegesPath, 'utf8'));

  let sql = `-- ============================================================
-- MYVAULT — FULL SUPABASE SETUP SQL
-- Run this in: Supabase Dashboard > SQL Editor > New query
-- ============================================================

-- ============================================================
-- STEP 1: DROP FAILING TRIGGER (root cause of 500 signup error)
-- ============================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- ============================================================
-- STEP 2: DROP EXISTING TABLES (clean slate - CASCADE removes deps)
-- ============================================================

DROP TABLE IF EXISTS course_enrollments CASCADE;
DROP TABLE IF EXISTS certificates CASCADE;
DROP TABLE IF EXISTS project_submissions CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS internship_applications CASCADE;
DROP TABLE IF EXISTS internships CASCADE;
DROP TABLE IF EXISTS results CASCADE;
DROP TABLE IF EXISTS academic_resources CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS colleges CASCADE;
DROP TABLE IF EXISTS universities CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS self_paced_courses CASCADE;

-- ============================================================
-- STEP 3: CREATE TABLES (fresh, correct schema)
-- ============================================================

CREATE TABLE universities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  state TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE colleges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id UUID REFERENCES universities(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  admin_email TEXT,
  state TEXT,
  district TEXT,
  type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE students (
  id UUID PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  display_name TEXT GENERATED ALWAYS AS (last_name || ' ' || first_name) STORED,
  full_name_aadhar TEXT,
  mobile TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  hall_ticket TEXT UNIQUE NOT NULL,
  university_id UUID REFERENCES universities(id),
  college_id UUID REFERENCES colleges(id),
  course TEXT,
  branch TEXT,
  semester TEXT,
  year_of_study INTEGER,
  passing_year INTEGER,
  gender TEXT,
  state TEXT,
  profile_pic_url TEXT,
  is_mobile_verified BOOLEAN DEFAULT FALSE,
  is_email_verified BOOLEAN DEFAULT FALSE,
  college_notified BOOLEAN DEFAULT FALSE,
  student_notified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT,
  branch TEXT NOT NULL,
  semester TEXT NOT NULL,
  subject_type TEXT DEFAULT 'academic',
  university_id UUID REFERENCES universities(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE academic_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  file_url TEXT,
  video_url TEXT,
  description TEXT,
  unit_number INTEGER,
  is_paid BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hall_ticket TEXT NOT NULL,
  student_id UUID REFERENCES students(id),
  university_id UUID REFERENCES universities(id),
  college_id UUID REFERENCES colleges(id),
  branch TEXT,
  semester TEXT,
  exam_type TEXT NOT NULL,
  subject_name TEXT NOT NULL,
  subject_code TEXT,
  internal_marks NUMERIC,
  external_marks NUMERIC,
  total_marks NUMERIC,
  max_marks NUMERIC DEFAULT 100,
  grade TEXT,
  status TEXT DEFAULT 'pass',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE internships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  company_name TEXT NOT NULL,
  sector TEXT NOT NULL,
  domain TEXT,
  location TEXT,
  mode TEXT DEFAULT 'hybrid',
  duration TEXT,
  stipend TEXT,
  skills_required TEXT,
  eligibility TEXT,
  description TEXT,
  apply_url TEXT,
  deadline DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE internship_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  internship_id UUID REFERENCES internships(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'applied',
  applied_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, internship_id)
);

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  project_type TEXT NOT NULL,
  category TEXT,
  domain TEXT,
  branch TEXT,
  description TEXT,
  tools_required TEXT,
  difficulty TEXT DEFAULT 'medium',
  reward_points INTEGER DEFAULT 500,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE project_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  upload_url TEXT,
  status TEXT DEFAULT 'submitted',
  certificate_url TEXT,
  reward_points INTEGER DEFAULT 0,
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  course_name TEXT,
  certificate_url TEXT,
  verification_id TEXT UNIQUE DEFAULT gen_random_uuid()::TEXT,
  issued_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  category TEXT DEFAULT 'general',
  link TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE self_paced_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  is_free BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE course_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id),
  course_id UUID REFERENCES self_paced_courses(id),
  is_completed BOOLEAN DEFAULT FALSE,
  enrolled_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- STEP 3: ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE internship_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first to avoid duplicate errors
DROP POLICY IF EXISTS "student own data" ON students;
DROP POLICY IF EXISTS "student own results" ON results;
DROP POLICY IF EXISTS "student own applications" ON internship_applications;
DROP POLICY IF EXISTS "student own submissions" ON project_submissions;
DROP POLICY IF EXISTS "student own certificates" ON certificates;
DROP POLICY IF EXISTS "student own enrollments" ON course_enrollments;
DROP POLICY IF EXISTS "public universities" ON universities;
DROP POLICY IF EXISTS "public colleges" ON colleges;
DROP POLICY IF EXISTS "public subjects" ON subjects;
DROP POLICY IF EXISTS "public resources" ON academic_resources;
DROP POLICY IF EXISTS "public internships" ON internships;
DROP POLICY IF EXISTS "public projects" ON projects;
DROP POLICY IF EXISTS "public notifications" ON notifications;
DROP POLICY IF EXISTS "public courses" ON self_paced_courses;

CREATE POLICY "student own data" ON students FOR ALL USING (auth.uid() = id);
CREATE POLICY "student own results" ON results FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own applications" ON internship_applications FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own submissions" ON project_submissions FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own certificates" ON certificates FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own enrollments" ON course_enrollments FOR ALL USING (student_id = auth.uid());

-- Allow INSERT for new student registration (auth user inserts their own row)
CREATE POLICY "student insert own data" ON students FOR INSERT WITH CHECK (auth.uid() = id);

-- Public read for master data
CREATE POLICY "public universities" ON universities FOR SELECT USING (TRUE);
CREATE POLICY "public colleges" ON colleges FOR SELECT USING (TRUE);
CREATE POLICY "public subjects" ON subjects FOR SELECT USING (TRUE);
CREATE POLICY "public resources" ON academic_resources FOR SELECT USING (TRUE);
CREATE POLICY "public internships" ON internships FOR SELECT USING (TRUE);
CREATE POLICY "public projects" ON projects FOR SELECT USING (TRUE);
CREATE POLICY "public notifications" ON notifications FOR SELECT USING (TRUE);
CREATE POLICY "public courses" ON self_paced_courses FOR SELECT USING (TRUE);

-- ============================================================
-- STEP 4: SEED UNIVERSITIES
-- ============================================================
INSERT INTO universities (id, name, code, state) VALUES
  ('${formatUniUuid("1")}', 'JNTUH Affiliated', 'JNTUH', 'Telangana'),
  ('${formatUniUuid("2")}', 'Osmania University Affiliated', 'OU', 'Telangana'),
  ('${formatUniUuid("3")}', 'Kakatiya University Affiliated', 'KU', 'Telangana'),
  ('${formatUniUuid("4")}', 'RGUKT Campuses', 'RGUKT', 'Telangana'),
  ('${formatUniUuid("5")}', 'Government Engineering Colleges', 'Govt', 'Telangana'),
  ('${formatUniUuid("6")}', 'National Institutes & Private Universities', 'National', 'Telangana')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, state = EXCLUDED.state;

-- ============================================================
-- STEP 5: SEED COLLEGES
-- ============================================================
INSERT INTO colleges (id, university_id, name, code, district, type, state) VALUES
`;

  const values = colleges.map(c => {
    const id = formatCollegeUuid(c.id);
    const uniId = formatUniUuid(c.universityId);
    const name = c.name.replace(/'/g, "''");
    const code = c.code.replace(/'/g, "''");
    const district = c.district ? c.district.replace(/'/g, "''") : '';
    const type = c.type ? c.type.replace(/'/g, "''") : '';
    const state = c.state ? c.state.replace(/'/g, "''") : 'Telangana';
    return `  ('${id}', '${uniId}', '${name}', '${code}', '${district}', '${type}', '${state}')`;
  });

  sql += values.join(',\n') + '\nON CONFLICT (code) DO UPDATE SET\n  name = EXCLUDED.name,\n  university_id = EXCLUDED.university_id,\n  district = EXCLUDED.district,\n  type = EXCLUDED.type,\n  state = EXCLUDED.state;\n\n';

  sql += `-- ============================================================
-- DONE! The app should now be able to register users.
-- ============================================================
SELECT 'Setup complete!' as status,
  (SELECT COUNT(*) FROM universities) as universities_count,
  (SELECT COUNT(*) FROM colleges) as colleges_count;
`;

  fs.writeFileSync('scripts/seed_remote_supabase.sql', sql);
  console.log('Successfully generated FULL SQL script at backend/scripts/seed_remote_supabase.sql');
  console.log('Lines:', sql.split('\n').length);
}

main().catch(console.error);
