import pkg from 'pg';
const { Client } = pkg;

const url = "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";

async function main() {
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  
  const res = await client.query(`
    SELECT tablename, tableowner 
    FROM pg_tables 
    WHERE schemaname = 'public'
    ORDER BY tablename;
  `);
  console.log("All tables in pg_tables public schema:");
  console.log(res.rows);

  await client.end();
}

main().catch(console.error);
