import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('--- CLEANING STUDENT PROFILE RECORDS ---');
  
  // Delete all student records where role = 'student'
  const deleted = await prisma.student.deleteMany({
    where: {
      role: 'student'
    }
  });
  console.log(`Deleted student records: ${deleted.count}`);
}

main()
  .catch(err => console.error(err))
  .finally(async () => {
    await prisma.$disconnect();
  });
