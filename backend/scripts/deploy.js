import { execSync } from 'child_process';
import { PrismaClient } from '@prisma/client';

console.log('--- Production Deploy Script ---');
console.log('DATABASE_URL is configured:', !!process.env.DATABASE_URL);
if (process.env.DATABASE_URL) {
  console.log('DATABASE_URL length:', process.env.DATABASE_URL.length);
}

if (process.env.DATABASE_URL) {
  try {
    console.log('\nDropping dependent RLS policies before database push...');
    const prisma = new PrismaClient();
    await prisma.$executeRawUnsafe('DROP POLICY IF EXISTS "admin view same college students" ON students;');
    await prisma.$disconnect();
    console.log('Dependent RLS policies dropped successfully.');
  } catch (err) {
    console.log('Warning/Error dropping policy:', err.message || err);
  }
}

try {
  console.log('\nRunning: npx prisma db push...');
  const pushOut = execSync('npx prisma db push --accept-data-loss', { encoding: 'utf8' });
  console.log(pushOut);
} catch (err) {
  console.error('\n❌ ERROR RUNNING PRISMA DB PUSH:');
  console.error('Status Code:', err.status);
  console.error('Stdout:', err.stdout);
  console.error('Stderr:', err.stderr);
  process.exit(1);
}

try {
  console.log('\nRunning: npm run db:seed...');
  const seedOut = execSync('npm run db:seed', { encoding: 'utf8' });
  console.log(seedOut);
} catch (err) {
  console.error('\n❌ ERROR RUNNING DB SEED:');
  console.error('Status Code:', err.status);
  console.error('Stdout:', err.stdout);
  console.error('Stderr:', err.stderr);
  process.exit(1);
}

try {
  console.log('\nRunning: node scripts/apply_policies.js...');
  const policyOut = execSync('node scripts/apply_policies.js', { encoding: 'utf8' });
  console.log(policyOut);
} catch (err) {
  console.error('\n❌ ERROR RUNNING APPLY POLICIES:');
  console.error('Status Code:', err.status);
  console.error('Stdout:', err.stdout);
  console.error('Stderr:', err.stderr);
  process.exit(1);
}

console.log('\n🚀 Launching Express Server (node src/server.js)...');
try {
  execSync('node src/server.js', { stdio: 'inherit' });
} catch (err) {
  console.error('\n❌ ERROR RUNNING EXPRESS SERVER:');
  console.error(err);
  process.exit(1);
}
