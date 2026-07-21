import { PrismaClient } from '@prisma/client';

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  const prisma = new PrismaClient({
    datasources: { db: { url } }
  });

  try {
    console.log("Deleting all records from academic_contents table...");
    const count = await prisma.$executeRawUnsafe(`DELETE FROM academic_contents;`);
    console.log(`Successfully deleted ${count} subject files/academic contents. Subject files area is now clean!`);
  } catch (err) {
    console.error("Error clearing academic_contents:", err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
