import pkg from 'pg';
const { Client } = pkg;

const url = "postgresql://postgres:jzqqWU5XbrckrIAD@db.oawomrlsitttrbulxgyk.supabase.co:5432/postgres?sslmode=require";

async function main() {
  console.log("Connecting directly to direct DB host...");
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  
  const res = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name");
  console.log("Tables found:");
  console.log(res.rows.map(r => r.table_name));
  
  await client.end();
}

main().catch(console.error);
