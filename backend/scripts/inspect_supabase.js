import pkg from 'pg';
const { Client } = pkg;

const url = "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";

async function main() {
  console.log("Connecting directly via pg to:", url.split('@').pop());
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  
  const res = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name");
  console.log("Tables in remote Supabase public schema:");
  console.log(res.rows.map(r => r.table_name));
  
  await client.end();
}

main().catch(console.error);
