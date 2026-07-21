import { PrismaClient } from '@prisma/client';

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  const prisma = new PrismaClient({
    datasources: { db: { url } }
  });

  try {
    console.log("Fetching all subjects from database...");
    const subjects = await prisma.$queryRawUnsafe(`SELECT id, name, code, branch, semester, subject_type FROM subjects ORDER BY branch, semester, name;`);
    console.log("Current subjects in database:", subjects);

    // List of known junk names or patterns
    const junkNames = ['WSN009', 'LDIC', 'jgv0', 'gvuygb', 'dld90'];

    console.log("\nDeleting specified junk subjects...");
    for (const j of junkNames) {
      const res = await prisma.$executeRawUnsafe(`DELETE FROM subjects WHERE LOWER(name) = LOWER('${j}') OR LOWER(code) = LOWER('${j}');`);
      console.log(`Deleted '${j}': ${res} row(s) removed.`);
    }

    // Also delete any subject name that looks like random garbage (e.g. jgv0, gvuygb, dld90)
    const cleanupRegex = await prisma.$executeRawUnsafe(`
      DELETE FROM subjects 
      WHERE name ~* '^[a-z0-9]{4,7}$' 
        AND name !~* '^(java|python|dsa|gate|apti|math|physics|chemistry)$';
    `);
    console.log(`Regex cleanup deleted ${cleanupRegex} additional junk subjects.`);

    // Check ECE Semester 1 subjects
    const eceS1 = await prisma.$queryRawUnsafe(`SELECT * FROM subjects WHERE branch = 'ECE' AND semester = 1;`);
    console.log("\nECE Semester 1 subjects after cleanup:", eceS1);

    // If ECE Semester 1 has no subjects or few subjects left, seed proper real ECE subjects
    if (eceS1.length === 0) {
      console.log("\nSeeding proper ECE Semester 1 subjects...");
      const realEceS1 = [
        { name: 'Mathematics - I', code: 'M101' },
        { name: 'Engineering Physics', code: 'EP102' },
        { name: 'Basic Electrical Engineering', code: 'BEE103' },
        { name: 'C Programming & Data Structures', code: 'CPDS104' },
        { name: 'Engineering Graphics & Design', code: 'EGD105' },
      ];

      for (const s of realEceS1) {
        await prisma.$executeRawUnsafe(`
          INSERT INTO subjects (id, name, code, branch, semester, subject_type)
          VALUES (gen_random_uuid(), '${s.name}', '${s.code}', 'ECE', 1, 'academic');
        `);
      }
      console.log("Successfully seeded proper ECE Semester 1 subjects!");
    }

    const finalSubjects = await prisma.$queryRawUnsafe(`SELECT id, name, code, branch, semester, subject_type FROM subjects WHERE branch = 'ECE' AND semester = 1;`);
    console.log("\nFinal ECE Semester 1 subjects in DB:", finalSubjects);

  } catch (err) {
    console.error("Error during junk subjects cleanup:", err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
