import pkg from 'pg';
const { Client } = pkg;

const c = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

await c.connect();
const r = await c.query(
  `SELECT table_name FROM information_schema.tables
   WHERE table_schema='public'
   AND table_name IN (
     'internship_courses','internship_opportunities','student_course_progress',
     'course_sections','course_videos','course_assignments',
     'course_certificates','assignment_submissions',
     'placement_jobs','student_saved_jobs'
   )
   ORDER BY table_name`
);
console.log(`Found ${r.rows.length} / 10 expected tables:`);
r.rows.forEach(row => console.log(' ✅', row.table_name));
if (r.rows.length < 10) {
  const found = r.rows.map(row => row.table_name);
  const expected = ['assignment_submissions','course_assignments','course_certificates','course_sections','course_videos','internship_courses','internship_opportunities','placement_jobs','student_course_progress','student_saved_jobs'];
  const missing = expected.filter(t => !found.includes(t));
  console.log('\n❌ Missing tables:');
  missing.forEach(t => console.log(' -', t));
}
await c.end();
