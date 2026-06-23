import dotenv from 'dotenv';

dotenv.config();

const targetDb = process.env.PG_DATABASE || 'myvault_db';
const base = process.env.DATABASE_URL || '';

// Connect to default "postgres" DB to create the app database
const adminUrl = base.replace(/\/([^/?]+)(\?.*)?$/, '/postgres$2');

async function main() {
  process.env.DATABASE_URL = adminUrl;
  const { default: prisma } = await import('../src/lib/prisma.js');

  try {
    await prisma.$executeRawUnsafe(`CREATE DATABASE "${targetDb}"`);
    console.log(`Created database: ${targetDb}`);
  } catch (err) {
    if (err.message?.includes('already exists')) {
      console.log(`Database already exists: ${targetDb}`);
    } else {
      throw err;
    }
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
