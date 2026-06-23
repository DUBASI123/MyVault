import { PrismaClient } from '@prisma/client';
import { execSync } from 'child_process';

const regions = [
  'ap-southeast-1', // Singapore
  'ap-south-1',     // Mumbai
  'us-east-1',      // N. Virginia
  'eu-central-1',   // Frankfurt
  'ap-southeast-2', // Sydney
  'ap-northeast-1', // Tokyo
  'ap-northeast-2', // Seoul
  'eu-west-2',      // London
  'us-west-2',      // Oregon
  'us-west-1',      // N. California
  'sa-east-1'       // São Paulo
];

async function testConnection(url) {
  const prisma = new PrismaClient({
    datasources: {
      db: { url }
    }
  });
  try {
    // Quick timeout query
    await prisma.$queryRaw`SELECT 1 as result`;
    await prisma.$disconnect();
    return true;
  } catch (err) {
    await prisma.$disconnect();
    return false;
  }
}

async function main() {
  const password = process.env.DATABASE_PASS || "guhQi7P6pbY14azd";
  const projectRef = "facqwktjfalukazexjye";
  const user = `postgres.${projectRef}`;

  console.log('--- Supabase Region Connection Auto-Discovery ---');
  let workingUrl = null;

  for (const region of regions) {
    const host = `aws-0-${region}.pooler.supabase.com`;
    const url = `postgresql://${user}:${encodeURIComponent(password)}@${host}:6543/postgres?sslmode=require&connection_limit=1`;
    console.log(`Checking connection to: ${region} (${host})...`);
    
    const ok = await testConnection(url);
    if (ok) {
      console.log(`\n🎉 FOUND WORKING REGION: ${region}`);
      workingUrl = url;
      break;
    }
  }

  if (!workingUrl) {
    console.error('\n❌ Could not connect to any Supabase region. Please double-check your database password.');
    process.exit(1);
  }

  // Set the environment variable for subsequent prisma commands
  process.env.DATABASE_URL = workingUrl;

  console.log('\n🚀 Starting Database Migration (prisma db push)...');
  execSync('npx prisma db push', { stdio: 'inherit', env: { ...process.env, DATABASE_URL: workingUrl } });

  console.log('\n🌱 Seeding Database (npm run db:seed)...');
  execSync('npm run db:seed', { stdio: 'inherit', env: { ...process.env, DATABASE_URL: workingUrl } });

  console.log('\n--- SUCCESS! ---');
  console.log('To run your server, update your Render DATABASE_URL environment variable to:');
  console.log(workingUrl.replace(/connection_limit=1/, 'pgbouncer=true'));
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
