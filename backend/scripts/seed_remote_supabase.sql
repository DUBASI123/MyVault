-- ============================================================
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
  ('00000000-0000-0000-0000-000000000001', 'JNTUH Affiliated', 'JNTUH', 'Telangana'),
  ('00000000-0000-0000-0000-000000000002', 'Osmania University Affiliated', 'OU', 'Telangana'),
  ('00000000-0000-0000-0000-000000000003', 'Kakatiya University Affiliated', 'KU', 'Telangana'),
  ('00000000-0000-0000-0000-000000000004', 'RGUKT Campuses', 'RGUKT', 'Telangana'),
  ('00000000-0000-0000-0000-000000000005', 'Government Engineering Colleges', 'Govt', 'Telangana'),
  ('00000000-0000-0000-0000-000000000006', 'National Institutes & Private Universities', 'National', 'Telangana')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, state = EXCLUDED.state;

-- ============================================================
-- STEP 5: SEED COLLEGES
-- ============================================================
INSERT INTO colleges (id, university_id, name, code, district, type, state) VALUES
  ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000001', 'A.M.R Institute of Technology', 'AIT', 'Adilabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000001', 'Abdul Kalam Institute of Technological Sciences', 'AKITS', 'Karimnagar', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000001', 'ACE Engineering College', 'AEC', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000104', '00000000-0000-0000-0000-000000000001', 'Adams Engineering College', 'AEC1', 'Khammam', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000105', '00000000-0000-0000-0000-000000000001', 'Adusumalli Vijaya College of Engineering and Research Centre', 'AVCERC', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000106', '00000000-0000-0000-0000-000000000001', 'Adusumalli Vijaya Institute of Technology', 'AVIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000107', '00000000-0000-0000-0000-000000000001', 'Aizza College of Engineering and Technology', 'ACET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000108', '00000000-0000-0000-0000-000000000001', 'Al-Habeeb College of Engineering and Technology', 'ACET1', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000109', '00000000-0000-0000-0000-000000000001', 'Amina Institute of Technology', 'AIT1', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000010a', '00000000-0000-0000-0000-000000000001', 'Anasuya Devi Institute of Technology and Sciences', 'ADITS', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000010b', '00000000-0000-0000-0000-000000000001', 'Anjamma Agi Reddy Engineering College for Women', 'AARECW', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000010c', '00000000-0000-0000-0000-000000000001', 'Annamacharya Institute of Technology and Sciences', 'AITS', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000010d', '00000000-0000-0000-0000-000000000001', 'Anu Bose Institute of Technology', 'ABIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000010e', '00000000-0000-0000-0000-000000000001', 'Anurag College of Engineering', 'ACE', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000010f', '00000000-0000-0000-0000-000000000001', 'Anurag Engineering College', 'AEC2', 'Nalgonda', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000110', '00000000-0000-0000-0000-000000000001', 'Aurora Group of Institutions', 'AGI', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000111', '00000000-0000-0000-0000-000000000001', 'Aurora Scientific Technological Institute', 'ASTI', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000112', '00000000-0000-0000-0000-000000000001', 'Balaji Institute of Technology and Science', 'BITS', 'Nalgonda', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000113', '00000000-0000-0000-0000-000000000001', 'Bharat Institute of Engineering and Technology', 'BIET', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000114', '00000000-0000-0000-0000-000000000001', 'Bhoj Reddy Engineering College for Women', 'BRECW', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000115', '00000000-0000-0000-0000-000000000001', 'BVRIT Hyderabad College of Engineering for Women', 'BHCEW', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000116', '00000000-0000-0000-0000-000000000001', 'BV Raju Institute of Technology', 'BRIT', 'Medak', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000117', '00000000-0000-0000-0000-000000000001', 'CMR College of Engineering and Technology', 'CCET', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000118', '00000000-0000-0000-0000-000000000001', 'CMR Engineering College', 'CEC', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000119', '00000000-0000-0000-0000-000000000001', 'CVR College of Engineering', 'CCE', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000011a', '00000000-0000-0000-0000-000000000001', 'Ellenki College of Engineering and Technology', 'ECET', 'Sangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000011b', '00000000-0000-0000-0000-000000000001', 'Geethanjali College of Engineering and Technology', 'GCET', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000011c', '00000000-0000-0000-0000-000000000001', 'Gokaraju Rangaraju Institute of Engineering and Technology', 'GRIET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000011d', '00000000-0000-0000-0000-000000000001', 'Guru Nanak Institutions Technical Campus', 'GNITC', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000011e', '00000000-0000-0000-0000-000000000001', 'Holy Mary Institute of Technology and Science', 'HMITS', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000011f', '00000000-0000-0000-0000-000000000001', 'J.B. Institute of Engineering and Technology', 'JIET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000120', '00000000-0000-0000-0000-000000000001', 'Joginpally B.R Engineering College', 'JBEC', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000121', '00000000-0000-0000-0000-000000000001', 'Kakatiya Institute of Technology and Science', 'KITS', 'Warangal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000122', '00000000-0000-0000-0000-000000000001', 'Keshav Memorial Institute of Technology', 'KMIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000123', '00000000-0000-0000-0000-000000000001', 'Kommuri Pratap Reddy Institute of Technology', 'KPRIT', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000124', '00000000-0000-0000-0000-000000000001', 'Mahatma Gandhi Institute of Technology', 'MGIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000125', '00000000-0000-0000-0000-000000000001', 'Malla Reddy College of Engineering', 'MRCE', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000126', '00000000-0000-0000-0000-000000000001', 'Malla Reddy Engineering College', 'MREC', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000127', '00000000-0000-0000-0000-000000000001', 'Malla Reddy Institute of Technology', 'MRIT', 'Medchal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000128', '00000000-0000-0000-0000-000000000001', 'Maturi Venkata Subba Rao Engineering College', 'MVSREC', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000129', '00000000-0000-0000-0000-000000000001', 'MLR Institute of Technology', 'MIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000012a', '00000000-0000-0000-0000-000000000001', 'Nalla Malla Reddy Engineering College', 'NMREC', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000012b', '00000000-0000-0000-0000-000000000001', 'Narsimha Reddy Engineering College', 'NREC', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000012c', '00000000-0000-0000-0000-000000000001', 'Princeton Institute of Engineering and Technology', 'PIET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000012d', '00000000-0000-0000-0000-000000000001', 'Sreyas Institute of Engineering and Technology', 'SIET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000012e', '00000000-0000-0000-0000-000000000001', 'Sreenidhi Institute of Science and Technology', 'SIST', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000012f', '00000000-0000-0000-0000-000000000001', 'Sri Indu College of Engineering and Technology', 'SICET', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000130', '00000000-0000-0000-0000-000000000001', 'St Martins Engineering College', 'SMEC', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000131', '00000000-0000-0000-0000-000000000001', 'TKR College of Engineering and Technology', 'TCET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000132', '00000000-0000-0000-0000-000000000001', 'Vardhaman College of Engineering', 'VCE', 'Rangareddy', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000133', '00000000-0000-0000-0000-000000000001', 'Vidya Jyothi Institute of Technology', 'VJIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000134', '00000000-0000-0000-0000-000000000001', 'Vignan Institute of Technology and Science', 'VITS', 'Nalgonda', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000135', '00000000-0000-0000-0000-000000000001', 'Vignana Bharathi Institute of Technology', 'VBIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000136', '00000000-0000-0000-0000-000000000001', 'VNR Vignana Jyothi Institute of Engineering and Technology', 'VVJIET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000137', '00000000-0000-0000-0000-000000000001', 'Vaageshwari College of Engineering', 'VCE1', 'Karimnagar', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000138', '00000000-0000-0000-0000-000000000001', 'Vaagdevi Engineering College', 'VEC', 'Hanamkonda', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000139', '00000000-0000-0000-0000-000000000002', 'Chaitanya Bharathi Institute of Technology', 'CBIT', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000013a', '00000000-0000-0000-0000-000000000002', 'University College of Engineering Osmania University', 'UCEOU', 'Hyderabad', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000013b', '00000000-0000-0000-0000-000000000002', 'Vasavi College of Engineering', 'VCE2', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000013c', '00000000-0000-0000-0000-000000000002', 'Muffakham Jah College of Engineering and Technology', 'MJCET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000013d', '00000000-0000-0000-0000-000000000002', 'Deccan College of Engineering and Technology', 'DCET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000013e', '00000000-0000-0000-0000-000000000002', 'ISL Engineering College', 'IEC', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000013f', '00000000-0000-0000-0000-000000000002', 'Lords Institute of Engineering and Technology', 'LIET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000140', '00000000-0000-0000-0000-000000000002', 'Methodist College of Engineering and Technology', 'MCET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000141', '00000000-0000-0000-0000-000000000002', 'Nawab Shah Alam Khan College of Engineering and Technology', 'NSAKCET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000142', '00000000-0000-0000-0000-000000000002', 'Stanley College of Engineering and Technology for Women', 'SCETW', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000143', '00000000-0000-0000-0000-000000000002', 'Anwar Ul Uloom College of Engineering and Technology', 'AUUCET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000144', '00000000-0000-0000-0000-000000000002', 'Mahaveer Institute of Science and Technology', 'MIST', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000145', '00000000-0000-0000-0000-000000000002', 'Matrusri Engineering College', 'MEC', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000146', '00000000-0000-0000-0000-000000000002', 'Shadan College of Engineering and Technology', 'SCET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000147', '00000000-0000-0000-0000-000000000002', 'Islamia College of Engineering and Technology', 'ICET', 'Hyderabad', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000148', '00000000-0000-0000-0000-000000000002', 'Khaja Banda Nawaz College of Engineering', 'KBNCE', 'Kalaburagi', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000149', '00000000-0000-0000-0000-000000000003', 'KITS Warangal', 'KW', 'Warangal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000014a', '00000000-0000-0000-0000-000000000003', 'KU College of Engineering and Technology', 'KCET', 'Warangal', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000014b', '00000000-0000-0000-0000-000000000003', 'KU College of Engineering Kothagudem', 'KCEK', 'Bhadradri Kothagudem', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000014c', '00000000-0000-0000-0000-000000000003', 'Vaagdevi Engineering College', 'VEC1', 'Hanamkonda', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000014d', '00000000-0000-0000-0000-000000000003', 'SR Engineering College', 'SEC', 'Warangal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000014e', '00000000-0000-0000-0000-000000000003', 'Christu Jyothi Institute of Technology and Science', 'CJITS', 'Warangal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-00000000014f', '00000000-0000-0000-0000-000000000003', 'Warangal Institute of Technology and Science', 'WITS', 'Hanamkonda', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000150', '00000000-0000-0000-0000-000000000003', 'Jayamukhi Institute of Technological Sciences', 'JITS', 'Warangal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000151', '00000000-0000-0000-0000-000000000003', 'Ganapathy Engineering College', 'GEC', 'Warangal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000152', '00000000-0000-0000-0000-000000000003', 'Mother Teresa Institute of Science and Technology', 'MTIST', 'Khammam', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000153', '00000000-0000-0000-0000-000000000003', 'Aurum Institute of Technology', 'AIT2', 'Warangal', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000154', '00000000-0000-0000-0000-000000000003', 'Vaageshwari Engineering College', 'VEC2', 'Karimnagar', 'Private', 'Telangana'),
  ('00000000-0000-0000-0000-000000000155', '00000000-0000-0000-0000-000000000004', 'RGUKT Basar', 'RB', 'Nirmal', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000156', '00000000-0000-0000-0000-000000000004', 'RGUKT Nuzvid', 'RN', 'Krishna', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000157', '00000000-0000-0000-0000-000000000004', 'RGUKT RK Valley', 'RRV', 'Kadapa', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000158', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Hyderabad', 'JCEH', 'Hyderabad', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000159', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Sultanpur', 'JCES', 'Medak', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000015a', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Jagtial', 'JCEJ', 'Jagitial', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000015b', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Manthani', 'JCEM', 'Peddapalli', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000015c', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Rajanna Sircilla', 'JCERS', 'Rajanna Sircilla', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000015d', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Wanaparthy', 'JCEW', 'Wanaparthy', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000015e', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Mahabubabad', 'JCEM1', 'Mahabubabad', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-00000000015f', '00000000-0000-0000-0000-000000000005', 'JNTUH College of Engineering Palair', 'JCEP', 'Khammam', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000160', '00000000-0000-0000-0000-000000000005', 'Osmania University College of Engineering', 'OUCE', 'Hyderabad', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000161', '00000000-0000-0000-0000-000000000005', 'Osmania University College of Technology', 'OUCT', 'Hyderabad', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000162', '00000000-0000-0000-0000-000000000005', 'KU College of Engineering and Technology', 'KCET1', 'Warangal', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000163', '00000000-0000-0000-0000-000000000005', 'Government Engineering College Kosgi', 'GECK', 'Mahabubnagar', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000164', '00000000-0000-0000-0000-000000000005', 'MGU College of Engineering and Technology', 'MCET1', 'Nalgonda', 'Government', 'Telangana'),
  ('00000000-0000-0000-0000-000000000165', '00000000-0000-0000-0000-000000000006', 'Indian Institute of Technology Hyderabad', 'IITH', 'Sangareddy', 'National Institute', 'Telangana'),
  ('00000000-0000-0000-0000-000000000166', '00000000-0000-0000-0000-000000000006', 'National Institute of Technology Warangal', 'NITW', 'Warangal', 'National Institute', 'Telangana'),
  ('00000000-0000-0000-0000-000000000167', '00000000-0000-0000-0000-000000000006', 'International Institute of Information Technology Hyderabad', 'IIITH', 'Hyderabad', 'Deemed University', 'Telangana'),
  ('00000000-0000-0000-0000-000000000168', '00000000-0000-0000-0000-000000000006', 'BITS Pilani Hyderabad Campus', 'BPHC', 'Hyderabad', 'Deemed University', 'Telangana'),
  ('00000000-0000-0000-0000-000000000169', '00000000-0000-0000-0000-000000000006', 'Mahindra University', 'MU', 'Hyderabad', 'Deemed University', 'Telangana'),
  ('00000000-0000-0000-0000-00000000016a', '00000000-0000-0000-0000-000000000006', 'Woxsen University', 'WU', 'Sangareddy', 'Deemed University', 'Telangana'),
  ('00000000-0000-0000-0000-00000000016b', '00000000-0000-0000-0000-000000000006', 'Anurag University', 'AU', 'Hyderabad', 'Deemed University', 'Telangana'),
  ('00000000-0000-0000-0000-00000000016c', '00000000-0000-0000-0000-000000000006', 'ICFAI Tech School', 'ITS', 'Hyderabad', 'Deemed University', 'Telangana')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  university_id = EXCLUDED.university_id,
  district = EXCLUDED.district,
  type = EXCLUDED.type,
  state = EXCLUDED.state;

-- ============================================================
-- DONE! The app should now be able to register users.
-- ============================================================
SELECT 'Setup complete!' as status,
  (SELECT COUNT(*) FROM universities) as universities_count,
  (SELECT COUNT(*) FROM colleges) as colleges_count;
