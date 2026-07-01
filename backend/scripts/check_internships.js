import { PrismaClient } from '@prisma/client';

const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
const prisma = new PrismaClient({ datasources: { db: { url } } });

async function main() {
  const count1 = await prisma.internship.count();
  const count2 = await prisma.$queryRawUnsafe('SELECT COUNT(*) FROM internship_opportunities');
  const count3 = await prisma.$queryRawUnsafe('SELECT COUNT(*) FROM internship_courses');
  
  console.log(`internships count: ${count1}`);
  console.log(`internship_opportunities count:`, count2[0].count);
  console.log(`internship_courses count:`, count3[0].count);
}

main().catch(console.error).finally(() => prisma.$disconnect());
