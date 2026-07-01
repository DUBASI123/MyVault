import pkg from 'pg';
const { Client } = pkg;

const url = "postgresql://postgres:jzqqWU5XbrckrIAD@db.oawomrlsitttrbulxgyk.supabase.co:5432/postgres?sslmode=require";

const sqls = [
  "GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;",
  "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;",
  "GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;",
  "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;",
  "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;",
  "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres, anon, authenticated, service_role;",
  "NOTIFY pgrst, 'reload schema';"
];

async function main() {
  console.log("Connecting directly via pg to grant permissions on all tables...");
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  
  console.log("Connected successfully! Executing GRANT statements...");
  for (const sql of sqls) {
    try {
      await client.query(sql);
      console.log(`✅ Success: ${sql}`);
    } catch (err) {
      console.error(`❌ Failed: ${sql}`);
      console.error(err.message);
    }
  }
  
  await client.end();
  console.log("\nDone!");
}

main().catch(console.error);
