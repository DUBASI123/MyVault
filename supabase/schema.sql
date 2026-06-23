-- ============================================================
-- UNIVERSITIES
-- ============================================================
CREATE TABLE IF NOT EXISTS universities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  state TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO universities (name, code, state) VALUES
  ('Jawaharlal Nehru Technological University Hyderabad', 'JNTUH', 'Telangana'),
  ('Osmania University Engineering', 'OUE-OU', 'Telangana'),
  ('RGUKT Basar', 'RGUKT', 'Telangana')
ON CONFLICT DO NOTHING;

-- ============================================================
-- COLLEGES
-- ============================================================
CREATE TABLE IF NOT EXISTS colleges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id UUID REFERENCES universities(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  admin_email TEXT,
  state TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- STUDENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS students (
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

-- ============================================================
-- SUBJECTS
-- ============================================================
CREATE TABLE IF NOT EXISTS subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT,
  branch TEXT NOT NULL,
  semester TEXT NOT NULL,
  subject_type TEXT DEFAULT 'academic',
  university_id UUID REFERENCES universities(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ACADEMIC RESOURCES
-- ============================================================
CREATE TABLE IF NOT EXISTS academic_resources (
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

-- ============================================================
-- RESULTS
-- ============================================================
CREATE TABLE IF NOT EXISTS results (
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

-- ============================================================
-- INTERNSHIPS
-- ============================================================
CREATE TABLE IF NOT EXISTS internships (
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

CREATE TABLE IF NOT EXISTS internship_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  internship_id UUID REFERENCES internships(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'applied',
  applied_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, internship_id)
);

-- ============================================================
-- PROJECTS
-- ============================================================
CREATE TABLE IF NOT EXISTS projects (
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

CREATE TABLE IF NOT EXISTS project_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  upload_url TEXT,
  status TEXT DEFAULT 'submitted',
  certificate_url TEXT,
  reward_points INTEGER DEFAULT 0,
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- CERTIFICATES
-- ============================================================
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  course_name TEXT,
  certificate_url TEXT,
  verification_id TEXT UNIQUE DEFAULT gen_random_uuid()::TEXT,
  issued_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  category TEXT DEFAULT 'general',
  link TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- SELF-PACED COURSES
-- ============================================================
CREATE TABLE IF NOT EXISTS self_paced_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  is_free BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS course_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id),
  course_id UUID REFERENCES self_paced_courses(id),
  is_completed BOOLEAN DEFAULT FALSE,
  enrolled_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE internship_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "student own data" ON students
  FOR ALL USING (auth.uid() = id);
CREATE POLICY "student own results" ON results
  FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own applications" ON internship_applications
  FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own submissions" ON project_submissions
  FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own certificates" ON certificates
  FOR ALL USING (student_id = auth.uid());
CREATE POLICY "student own enrollments" ON course_enrollments
  FOR ALL USING (student_id = auth.uid());

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
-- REGISTRATION NOTIFICATION TRIGGER
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION trigger_registration_notification()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  PERFORM net.http_post(
    url := current_setting('app.supabase_url') || '/functions/v1/notify-registration',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    ),
    body := jsonb_build_object(
      'student_id', NEW.id,
      'first_name', NEW.first_name,
      'last_name', NEW.last_name,
      'hall_ticket', NEW.hall_ticket,
      'email', NEW.email,
      'mobile', NEW.mobile,
      'college_id', NEW.college_id
    )
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_student_registered
  AFTER INSERT ON students
  FOR EACH ROW
  EXECUTE FUNCTION trigger_registration_notification();
