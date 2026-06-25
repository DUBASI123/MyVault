import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('--- REMOTE DB INSPECTION ---');
  
  // 1. Check colleges
  const colleges = await prisma.college.findMany({
    orderBy: { name: 'asc' }
  });
  console.log(`\nColleges found (${colleges.length}):`);
  colleges.forEach(c => {
    console.log(`- [${c.id}] ${c.name} (${c.code || 'No Code'})`);
  });

  // 2. Check all student/admin accounts
  const accounts = await prisma.student.findMany({
    include: { college: true }
  });
  console.log(`\nAccounts found (${accounts.length}):`);
  accounts.forEach(a => {
    console.log(`- ID: ${a.id}`);
    console.log(`  Name: ${a.firstName} ${a.lastName}`);
    console.log(`  Email: ${a.email}`);
    console.log(`  Mobile: ${a.mobile}`);
    console.log(`  Role: ${a.role}`);
    console.log(`  College: ${a.college?.name} (${a.collegeId})`);
    console.log(`  Verified: ${a.isVerified} (Status: ${a.verificationStatus})`);
    console.log(`  Created: ${a.createdAt}`);
    console.log('------------------------------');
  });
}

main()
  .catch(err => console.error(err))
  .finally(async () => {
    await prisma.$disconnect();
  });
