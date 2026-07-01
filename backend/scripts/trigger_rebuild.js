import pkg from 'pg';
const { Client } = pkg;

const url = "postgresql://postgres:jzqqWU5XbrckrIAD@db.oawomrlsitttrbulxgyk.supabase.co:5432/postgres?sslmode=require";

const tables = [
  "internship_courses",
  "course_sections",
  "course_videos",
  "course_assignments",
  "course_test_questions",
  "student_course_progress",
  "assignment_submissions",
  "course_certificates",
  "internship_opportunities",
  "placement_jobs",
  "student_saved_jobs"
];

async function main() {
  console.log("Connecting to direct database to force schema cache rebuild...");
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  
  for (const table of tables) {
    try {
      console.log(`Forcing rebuild on table: ${table}...`);
      await client.query(`ALTER TABLE ${table} ADD COLUMN temp_rebuild_cache_val BOOLEAN;`);
      await client.query(`ALTER TABLE ${table} DROP COLUMN temp_rebuild_cache_val;`);
      console.log(`✅ Table ${table} schema changed & restored.`);
    } catch (err) {
      console.error(`❌ Failed on table ${table}:`, err.message);
    }
  }
  
  console.log("\nReloading schema notification...");
  await client.query("NOTIFY pgrst, 'reload schema';");
  console.log("✅ Complete!");
  
  await client.end();
}

main().catch(console.error);
