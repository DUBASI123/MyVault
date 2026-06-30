import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';
dotenv.config();

const prisma = new PrismaClient();

async function main() {
  console.log('Connecting to database to fix foreign key constraints...');
  
  const queries = [
    // 1. internship_courses (created_by)
    'ALTER TABLE internship_courses DROP CONSTRAINT IF EXISTS internship_courses_created_by_fkey;',
    
    // 2. student_course_progress (student_id)
    'ALTER TABLE student_course_progress DROP CONSTRAINT IF EXISTS student_course_progress_student_id_fkey;',
    'ALTER TABLE student_course_progress ADD CONSTRAINT student_course_progress_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE;',
    
    // 3. assignment_submissions (student_id)
    'ALTER TABLE assignment_submissions DROP CONSTRAINT IF EXISTS assignment_submissions_student_id_fkey;',
    'ALTER TABLE assignment_submissions ADD CONSTRAINT assignment_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE;',
    
    // 4. course_certificates (student_id)
    'ALTER TABLE course_certificates DROP CONSTRAINT IF EXISTS course_certificates_student_id_fkey;',
    'ALTER TABLE course_certificates ADD CONSTRAINT course_certificates_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE;',
    
    // 5. internship_opportunities (posted_by)
    'ALTER TABLE internship_opportunities DROP CONSTRAINT IF EXISTS internship_opportunities_posted_by_fkey;'
  ];

  for (const query of queries) {
    try {
      console.log(`Executing: ${query}`);
      await prisma.$executeRawUnsafe(query);
      console.log('Success!');
    } catch (err) {
      console.error(`Failed to execute: ${query}`, err.message || err);
    }
  }

  await prisma.$disconnect();
  console.log('Constraint fixing completed.');
}

main();
