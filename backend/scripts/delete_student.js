import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const identifier = process.argv[2];
  if (!identifier) {
    console.log('\n--- DELETE STUDENT RECORD ---');
    console.log('Usage: node backend/scripts/delete_student.js <email_or_mobile_or_hallticket>\n');
    return;
  }

  const target = identifier.trim().toLowerCase();
  
  // Find the student
  const student = await prisma.student.findFirst({
    where: {
      OR: [
        { email: target },
        { mobile: target },
        { mobile: '+' + target },
        { hallTicket: identifier.trim() }
      ]
    }
  });

  if (!student) {
    console.log(`\n❌ Error: No student record found matching "${identifier}".`);
    return;
  }

  // Delete from students table
  await prisma.student.delete({
    where: { id: student.id }
  });

  console.log(`\n✅ Success: Student "${student.firstName} ${student.lastName}" has been deleted from the database.`);
  console.log(`👉 Note: The mobile number "${student.mobile}" and Hall Ticket "${student.hallTicket}" are now free to be registered again.`);
  console.log('👉 IMPORTANT: If your authentication provider (Supabase Auth) still has this email registered, please delete it from the Supabase Dashboard (Authentication -> Users) before retrying the same email.\n');
}

main()
  .catch(err => {
    console.error('An error occurred:', err);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
