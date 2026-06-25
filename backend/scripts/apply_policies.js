import { PrismaClient } from '@prisma/client';

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  const prisma = new PrismaClient({
    datasources: {
      db: { url }
    }
  });

  const sqls = [
    // 1. Students
    "ALTER TABLE students ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"student own data\" ON students;",
    "CREATE POLICY \"student own data\" ON students FOR ALL USING (auth.uid()::text = id);",
    "DROP POLICY IF EXISTS \"admin view same college students\" ON students;",
    "CREATE POLICY \"admin view same college students\" ON students FOR ALL USING (EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid()::text AND admins.college_id = students.college_id));",

    // 2. Internship Applications
    "ALTER TABLE internship_applications ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"student own applications\" ON internship_applications;",
    "CREATE POLICY \"student own applications\" ON internship_applications FOR ALL USING (student_id = auth.uid()::text);",

    // 3. Project Submissions
    "ALTER TABLE project_submissions ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"student own submissions\" ON project_submissions;",
    "CREATE POLICY \"student own submissions\" ON project_submissions FOR ALL USING (student_id = auth.uid()::text);",

    // 4. Certificates
    "ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"student own certificates\" ON certificates;",
    "CREATE POLICY \"student own certificates\" ON certificates FOR ALL USING (student_id = auth.uid()::text);",

    // 5. Universities
    "ALTER TABLE universities ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"public universities\" ON universities;",
    "CREATE POLICY \"public universities\" ON universities FOR SELECT USING (TRUE);",

    // 6. Colleges
    "ALTER TABLE colleges ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"public colleges\" ON colleges;",
    "CREATE POLICY \"public colleges\" ON colleges FOR SELECT USING (TRUE);",

    // 7. Subjects
    "ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"public subjects\" ON subjects;",
    "CREATE POLICY \"public subjects\" ON subjects FOR SELECT USING (TRUE);",

    // 8. Academic Contents
    "ALTER TABLE academic_contents ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"public contents\" ON academic_contents;",
    "CREATE POLICY \"public contents\" ON academic_contents FOR SELECT USING (TRUE);",

    // 9. Internships
    "ALTER TABLE internships ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"public internships\" ON internships;",
    "CREATE POLICY \"public internships\" ON internships FOR SELECT USING (TRUE);",

    // 10. Projects
    "ALTER TABLE projects ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"public projects\" ON projects;",
    "CREATE POLICY \"public projects\" ON projects FOR SELECT USING (TRUE);",

    // 11. Notifications
    "ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"public notifications\" ON notifications;",
    "CREATE POLICY \"public notifications\" ON notifications FOR SELECT USING (TRUE);",

    // 12. Admins
    "ALTER TABLE admins ENABLE ROW LEVEL SECURITY;",
    "DROP POLICY IF EXISTS \"admin own record\" ON admins;",
    "CREATE POLICY \"admin own record\" ON admins FOR ALL USING (auth.uid()::text = id);"
  ];

  try {
    console.log("Applying Supabase RLS security policies...");
    for (const sql of sqls) {
      console.log(`Executing: ${sql}`);
      await prisma.$executeRawUnsafe(sql);
    }
    console.log("🎉 All security policies and RLS rules applied successfully!");
  } catch (error) {
    console.error("❌ Error applying policies:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
