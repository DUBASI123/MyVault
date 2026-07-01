import { PrismaClient } from '@prisma/client';

const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
const prisma = new PrismaClient({ datasources: { db: { url } } });

const sqls = [
  'ALTER TABLE internship_courses ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS courses_read_all ON internship_courses;',
  'CREATE POLICY courses_read_all ON internship_courses FOR SELECT USING (TRUE);',
  'ALTER TABLE course_sections ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS sections_read_all ON course_sections;',
  'CREATE POLICY sections_read_all ON course_sections FOR SELECT USING (TRUE);',
  'ALTER TABLE course_videos ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS videos_read_all ON course_videos;',
  'CREATE POLICY videos_read_all ON course_videos FOR SELECT USING (TRUE);',
  'ALTER TABLE course_assignments ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS assignments_read_all ON course_assignments;',
  'CREATE POLICY assignments_read_all ON course_assignments FOR SELECT USING (TRUE);',
  'ALTER TABLE course_test_questions ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS questions_read_all ON course_test_questions;',
  'CREATE POLICY questions_read_all ON course_test_questions FOR SELECT USING (TRUE);',
  'ALTER TABLE student_course_progress ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS progress_own ON student_course_progress;',
  'CREATE POLICY progress_own ON student_course_progress FOR ALL USING (TRUE);',
  'ALTER TABLE course_certificates ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS certs_own ON course_certificates;',
  'CREATE POLICY certs_own ON course_certificates FOR ALL USING (TRUE);',
  'ALTER TABLE internship_opportunities ENABLE ROW LEVEL SECURITY;',
  'DROP POLICY IF EXISTS opp_read_all ON internship_opportunities;',
  'CREATE POLICY opp_read_all ON internship_opportunities FOR SELECT USING (TRUE);',
];

async function main() {
  console.log('Applying RLS policies for internship tables...');
  for (const sql of sqls) {
    try {
      await prisma.$executeRawUnsafe(sql);
      console.log('OK:', sql.substring(0, 70));
    } catch (e) {
      console.log('SKIP:', e.message.substring(0, 100));
    }
  }
  await prisma.$disconnect();
  console.log('\n✅ Done!');
}

main();
