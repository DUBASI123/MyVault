import pkg from 'pg';
const { Client } = pkg;

const url = "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";

async function main() {
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  
  // 1. Check table owner
  const resOwner = await client.query(`
    SELECT tablename, tableowner 
    FROM pg_tables 
    WHERE schemaname = 'public' AND tablename = 'internship_courses';
  `);
  console.log("Table Owner:", resOwner.rows[0]);
  
  // 2. Check table grants
  const resGrants = await client.query(`
    SELECT grantee, privilege_type 
    FROM information_schema.role_table_grants 
    WHERE table_name = 'internship_courses';
  `);
  console.log("Table Grants:", resGrants.rows);

  await client.end();
}

main().catch(console.error);
