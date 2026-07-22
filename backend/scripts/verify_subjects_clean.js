import { PrismaClient } from '@prisma/client';

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  const prisma = new PrismaClient({ datasources: { db: { url } } });

  try {
    console.log("=== VERIFYING SUPABASE DATABASE CLEANUP ===");

    // 1. Check for any leftover junk subjects
    const junkMatches = await prisma.$queryRawUnsafe(`
      SELECT id, name, code, branch, semester 
      WHERE LOWER(name) IN ('wsn009', 'ldic', 'jgv0', 'gvuygb', 'dld90')
         OR LOWER(code) IN ('wsn009', 'ldic', 'jgv0', 'gvuygb', 'dld90');
    `).catch(() => []);

    console.log(`Junk subjects remaining: ${junkMatches.length}`);

    // 2. Cascade delete any residual academic_contents for junk subjects if any exist
    await prisma.$executeRawUnsafe(`
      DELETE FROM academic_contents 
      WHERE subject_id IN (
        SELECT id FROM subjects 
        WHERE LOWER(name) IN ('wsn009', 'ldic', 'jgv0', 'gvuygb', 'dld90')
           OR LOWER(code) IN ('wsn009', 'ldic', 'jgv0', 'gvuygb', 'dld90')
           OR name ~* '^[a-z0-9]{3,7}$' AND name !~* '^(java|python|dsa|gate|apti|math|physics|chemistry|dbms)$'
      );
    `);

    await prisma.$executeRawUnsafe(`
      DELETE FROM subjects 
      WHERE LOWER(name) IN ('wsn009', 'ldic', 'jgv0', 'gvuygb', 'dld90')
         OR LOWER(code) IN ('wsn009', 'ldic', 'jgv0', 'gvuygb', 'dld90')
         OR (name ~* '^[a-z0-9]{3,7}$' AND name !~* '^(java|python|dsa|gate|apti|math|physics|chemistry|dbms)$');
    `);

    // 3. Count total subjects in DB per branch & semester
    const eceSubjects = await prisma.$queryRawUnsafe(`
      SELECT id, name, code, branch, semester FROM subjects WHERE branch = 'ECE' ORDER BY semester, name;
    `);

    console.log(`\nECE Subjects currently in DB (${eceSubjects.length} total):`);
    console.table(eceSubjects);

  } catch (err) {
    console.error("Verification error:", err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
