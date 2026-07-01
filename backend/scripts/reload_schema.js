import pkg from 'pg';
const { Client } = pkg;

// Use the direct database connection hostname (bypassing pooler)
const url = "postgresql://postgres:jzqqWU5XbrckrIAD@db.oawomrlsitttrbulxgyk.supabase.co:5432/postgres?sslmode=require";

async function main() {
  console.log("Connecting directly via pg to db.oawomrlsitttrbulxgyk.supabase.co...");
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  
  console.log("Connected! Reloading PostgREST schema cache...");
  await client.query("NOTIFY pgrst, 'reload schema';");
  console.log("✅ PostgREST schema cache reload notification sent successfully!");
  
  await client.end();
}

main().catch(console.error);
