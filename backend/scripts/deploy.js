import { execSync } from 'child_process';
import { PrismaClient } from '@prisma/client';

console.log('--- Production NestJS Deploy Script ---');
console.log('DATABASE_URL is configured:', !!process.env.DATABASE_URL);
if (process.env.DATABASE_URL) {
  console.log('DATABASE_URL length:', process.env.DATABASE_URL.length);
}

if (process.env.DATABASE_URL) {
  try {
    console.log('\nDropping dependent RLS policies before database push...');
    const dbUrl = process.env.DATABASE_URL?.includes('pgbouncer=true')
      ? process.env.DATABASE_URL
      : `${process.env.DATABASE_URL}${process.env.DATABASE_URL?.includes('?') ? '&' : '?'}pgbouncer=true`;
    const prisma = new PrismaClient({ datasources: { db: { url: dbUrl } } });

    await prisma.$executeRawUnsafe('DROP POLICY IF EXISTS "admin view same college students" ON students;');
    await prisma.$disconnect();
    console.log('Dependent RLS policies dropped successfully.');
  } catch (err) {
    console.log('Warning/Error dropping policy:', err.message || err);
  }
}

try {
  console.log('\nRunning: npm run db:seed...');
  const seedOut = execSync('npm run db:seed', { encoding: 'utf8' });
  console.log(seedOut);
} catch (err) {
  console.warn('\n⚠️  WARNING: db:seed exited with an error (data may already be seeded). Continuing deploy...');
  console.warn('Stdout:', err.stdout?.slice(0, 500) || '(none)');
  console.warn('Stderr:', err.stderr?.slice(0, 500) || '(none)');
}

try {
  console.log('\nRunning: node scripts/apply_policies.js...');
  const policyOut = execSync('node scripts/apply_policies.js', { encoding: 'utf8' });
  console.log(policyOut);
} catch (err) {
  console.warn('\n⚠️  WARNING: apply_policies exited with an error. Continuing deploy...');
  console.warn('Stderr:', err.stderr?.slice(0, 300) || '(none)');
}

console.log('\n🚀 Launching NestJS Server (node dist/main.js)...');
try {
  execSync('node dist/main.js', { stdio: 'inherit' });
} catch (err) {
  console.error('\n❌ ERROR RUNNING NESTJS SERVER:');
  console.error(err);
  process.exit(1);
}
