import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('--- CLEANING AUTH USERS ---');
  
  // Delete all users from auth.users table
  const deleted = await prisma.$executeRawUnsafe(`
    DELETE FROM auth.users;
  `);
  console.log(`Deleted auth users: ${deleted}`);
}

main()
  .catch(err => console.error(err))
  .finally(async () => {
    await prisma.$disconnect();
  });
