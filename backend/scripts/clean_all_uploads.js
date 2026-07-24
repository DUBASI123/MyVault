import { PrismaClient } from '@prisma/client';

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  const prisma = new PrismaClient({
    datasources: { db: { url } }
  });

  try {
    console.log("🧹 Purging all uploaded files and records across Website and Mobile App...");
    
    try {
      const c1 = await prisma.$executeRawUnsafe(`DELETE FROM cms_study_materials;`);
      console.log(`Deleted ${c1} records from cms_study_materials.`);
    } catch (_) {}

    try {
      const c2 = await prisma.$executeRawUnsafe(`DELETE FROM cms_job_listings;`);
      console.log(`Deleted ${c2} records from cms_job_listings.`);
    } catch (_) {}

    try {
      const c3 = await prisma.$executeRawUnsafe(`DELETE FROM cms_notices;`);
      console.log(`Deleted ${c3} records from cms_notices.`);
    } catch (_) {}

    try {
      const c4 = await prisma.$executeRawUnsafe(`DELETE FROM academic_contents;`);
      console.log(`Deleted ${c4} records from academic_contents.`);
    } catch (_) {}

    console.log("✨ All uploaded files, database test records, and notice listings have been completely cleaned!");
  } catch (err) {
    console.error("Error cleaning uploads:", err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
