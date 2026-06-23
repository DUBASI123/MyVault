import { PrismaClient } from '@prisma/client';

async function testConnection(url) {
  console.log('Testing connection to:', url.replace(/:[^:@]+@/, ':***@'));
  const prisma = new PrismaClient({
    datasources: {
      db: { url }
    }
  });
  try {
    const res = await prisma.$queryRaw`SELECT 1 as result`;
    console.log('Success! Result:', res);
    await prisma.$disconnect();
    return true;
  } catch (err) {
    console.error('Failed:', err.message);
    await prisma.$disconnect();
    return false;
  }
}

async function main() {
  const host = 'db.facqwktjfalukazexjye.supabase.co';
  const passwords = ['password', 'postgres', 'postgres123', 'MyVaultPassword'];
  const ports = [5432, 6543];

  for (const password of passwords) {
    for (const port of ports) {
      const url = `postgresql://postgres:${password}@${host}:${port}/postgres?sslmode=require`;
      const ok = await testConnection(url);
      if (ok) {
        console.log('\nCONNECTED SUCCESSFUL WITH PASSWORD:', password, 'PORT:', port);
        process.exit(0);
      }
    }
  }
  console.log('\nAll connection attempts failed.');
  process.exit(1);
}

main();
