import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  // 1. Super Admin
  const superEmail = 'admin@stuvault.com';
  const superPassword = 'AdminPassword123';
  const superHash = await bcrypt.hash(superPassword, 10);

  const superAdmin = await prisma.student.upsert({
    where: { email: superEmail },
    update: {
      role: 'super_admin',
      status: 'APPROVED',
    },
    create: {
      firstName: 'Super',
      lastName: 'Admin',
      fullNameAadhar: 'Super Admin',
      mobile: '9999999999',
      email: superEmail,
      passwordHash: superHash,
      hallTicket: 'ADMIN001',
      course: 'N/A',
      branch: 'N/A',
      semester: 1,
      yearOfStudy: 1,
      role: 'super_admin',
      status: 'APPROVED',
      isMobileVerified: true,
      isEmailVerified: true,
    },
  });

  console.log('✅ Super Admin user created/updated successfully:');
  console.log(`📧 Email: ${superAdmin.email}`);
  console.log(`🔑 Password: ${superPassword}`);
  console.log(`👤 Role: ${superAdmin.role}`);

  // 2. Dept Admin
  const deptEmail = 'deptadmin@stuvault.com';
  const deptPassword = 'DeptPassword123';
  const deptHash = await bcrypt.hash(deptPassword, 10);

  const deptAdmin = await prisma.student.upsert({
    where: { email: deptEmail },
    update: {
      role: 'dept_admin',
      status: 'APPROVED',
      collegeId: 'c_1',
      branch: 'CSE',
    },
    create: {
      firstName: 'CSE Dept',
      lastName: 'Admin',
      fullNameAadhar: 'CSE Dept Admin',
      mobile: '8888888888',
      email: deptEmail,
      passwordHash: deptHash,
      hallTicket: 'ADMIN002',
      course: 'B.Tech',
      branch: 'CSE',
      collegeId: 'c_1',
      universityId: '1',
      semester: 1,
      yearOfStudy: 1,
      role: 'dept_admin',
      status: 'APPROVED',
      isMobileVerified: true,
      isEmailVerified: true,
    },
  });

  console.log('\n✅ Dept Admin user created/updated successfully:');
  console.log(`📧 Email: ${deptAdmin.email}`);
  console.log(`🔑 Password: ${deptPassword}`);
  console.log(`🏫 College ID: ${deptAdmin.collegeId}`);
  console.log(`📚 Branch: ${deptAdmin.branch}`);
  console.log(`👤 Role: ${deptAdmin.role}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
