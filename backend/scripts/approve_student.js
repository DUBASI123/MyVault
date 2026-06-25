import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const email = process.argv[2];
  
  if (!email) {
    console.log('\n--- PENDING STUDENT REGISTRATIONS ---');
    const pending = await prisma.student.findMany({
      where: { verificationStatus: 'Pending' },
      include: { college: true }
    });
    
    if (pending.length === 0) {
      console.log('No pending registrations found.');
    } else {
      console.log(`Found ${pending.length} pending registration(s):\n`);
      pending.forEach(s => {
        console.log(`- Email: ${s.email}`);
        console.log(`  Name: ${s.firstName} ${s.lastName}`);
        console.log(`  Mobile: ${s.mobile}`);
        console.log(`  Hall Ticket: ${s.hallTicket}`);
        console.log(`  College: ${s.college?.name || 'Unknown'} (${s.collegeId})`);
        console.log('  ------------------------------------------');
      });
      console.log('\n👉 To approve a student, run:');
      console.log('   node backend/scripts/approve_student.js <student_email>\n');
    }
    return;
  }

  const normalizedEmail = email.trim().toLowerCase();
  const student = await prisma.student.findUnique({
    where: { email: normalizedEmail }
  });

  if (!student) {
    console.error(`\n❌ Error: Student with email "${email}" not found.`);
    return;
  }

  await prisma.student.update({
    where: { id: student.id },
    data: {
      verificationStatus: 'Approved',
      isVerified: true,
      rejectionReason: null
    }
  });

  console.log(`\n✅ Success: Student "${student.firstName} ${student.lastName}" (${student.email}) has been approved!`);
  console.log('They can now log in to the MyVault mobile app.\n');
}

main()
  .catch(err => {
    console.error('An error occurred:', err);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
