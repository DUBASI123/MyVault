// ============================================================
// backend/scripts/seed_all_features.js
// ============================================================
import { PrismaClient } from '@prisma/client';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  
  console.log("Connecting to Database at URL:", url.includes('@') ? url.split('@').pop() : url.substring(0, 30) + "...");
  
  const prisma = new PrismaClient({
    datasources: {
      db: { url }
    }
  });

  try {
    // 1. Ensure subject_type column exists
    console.log("Ensuring database schema columns are present...");
    await prisma.$executeRawUnsafe(`
      ALTER TABLE subjects ADD COLUMN IF NOT EXISTS subject_type TEXT DEFAULT 'academic';
    `);

    // 2. Clear existing custom subjects and exam results
    console.log("Clearing existing seed data...");
    await prisma.$executeRawUnsafe(`DELETE FROM exam_results;`);
    await prisma.$executeRawUnsafe(`DELETE FROM academic_contents WHERE subject_id IN (SELECT id FROM subjects WHERE subject_type IN ('tech_skill', 'exam_prep', 'comm_skill'));`);
    await prisma.$executeRawUnsafe(`DELETE FROM subjects WHERE subject_type IN ('tech_skill', 'exam_prep', 'comm_skill');`);
    await prisma.$executeRawUnsafe(`DELETE FROM project_submissions;`);
    await prisma.$executeRawUnsafe(`DELETE FROM projects;`);
    await prisma.$executeRawUnsafe(`DELETE FROM notifications;`);

    // 3. Seed subjects for Tech Skills, Exam Prep, Comm Skills
    console.log("Seeding subjects...");
    
    // Tech Skills Subjects
    const s_java = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'Java Programming', 'TECH_JAVA', 'CSE', 3, 'tech_skill') RETURNING id;
    `))[0].id;

    const s_python = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'Python for Beginners', 'TECH_PY', 'CSE', 3, 'tech_skill') RETURNING id;
    `))[0].id;

    const s_flutter = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'Flutter & Dart SDK', 'TECH_FLUT', 'CSE', 3, 'tech_skill') RETURNING id;
    `))[0].id;

    const s_dsa = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'Data Structures & Algorithms', 'TECH_DSA', 'CSE', 3, 'tech_skill') RETURNING id;
    `))[0].id;

    // Exam Prep Subjects
    const s_apti = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'Aptitude & Logical Reasoning', 'EXAM_APTI', 'CSE', 4, 'exam_prep') RETURNING id;
    `))[0].id;

    const s_gate = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'GATE Computer Science Prep', 'EXAM_GATE', 'CSE', 4, 'exam_prep') RETURNING id;
    `))[0].id;

    // Comm Skills Subjects
    const s_comm = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'Business Communication & Etiquette', 'COMM_BIZ', 'CSE', 1, 'comm_skill') RETURNING id;
    `))[0].id;

    const s_soft = (await prisma.$queryRawUnsafe(`
      INSERT INTO subjects (id, name, code, branch, semester, subject_type)
      VALUES (gen_random_uuid(), 'Soft Skills & Leadership', 'COMM_SOFT', 'CSE', 1, 'comm_skill') RETURNING id;
    `))[0].id;

    // 4. Clear Academic Contents
    console.log("Clearing academic contents for clean subject environment...");
    await prisma.$executeRawUnsafe(`DELETE FROM academic_contents;`);


    // 5. Seed Exam Results
    console.log("Seeding exam results...");
    const results = [
      // Semester 1
      { subject: 'Mathematics - I', code: 'M101', internal: 28, external: 62, total: 90, maxMarks: 100, grade: 'O', status: 'Pass', semester: 1, branch: 'CSE' },
      { subject: 'Engineering Physics', code: 'P102', internal: 22, external: 48, total: 70, maxMarks: 100, grade: 'A', status: 'Pass', semester: 1, branch: 'CSE' },
      { subject: 'Programming in C', code: 'C103', internal: 25, external: 55, total: 80, maxMarks: 100, grade: 'A+', status: 'Pass', semester: 1, branch: 'CSE' },
      { subject: 'English Communication', code: 'E104', internal: 24, external: 41, total: 65, maxMarks: 100, grade: 'B+', status: 'Pass', semester: 1, branch: 'CSE' },
      
      // Semester 2
      { subject: 'Mathematics - II', code: 'M201', internal: 27, external: 58, total: 85, maxMarks: 100, grade: 'A+', status: 'Pass', semester: 2, branch: 'CSE' },
      { subject: 'Engineering Chemistry', code: 'C202', internal: 20, external: 45, total: 65, maxMarks: 100, grade: 'B+', status: 'Pass', semester: 2, branch: 'CSE' },
      { subject: 'OOPS through Java', code: 'J203', internal: 26, external: 50, total: 76, maxMarks: 100, grade: 'A', status: 'Pass', semester: 2, branch: 'CSE' },
      { subject: 'Digital Logic Design', code: 'D204', internal: 19, external: 41, total: 60, maxMarks: 100, grade: 'B', status: 'Pass', semester: 2, branch: 'CSE' },

      // Semester 3
      { subject: 'Data Structures & Algorithms', code: 'CS301', internal: 29, external: 61, total: 90, maxMarks: 100, grade: 'O', status: 'Pass', semester: 3, branch: 'CSE' },
      { subject: 'Discrete Mathematics', code: 'CS302', internal: 18, external: 35, total: 53, maxMarks: 100, grade: 'C', status: 'Pass', semester: 3, branch: 'CSE' },
      { subject: 'Computer Organization & Arch', code: 'CS303', internal: 22, external: 46, total: 68, maxMarks: 100, grade: 'B+', status: 'Pass', semester: 3, branch: 'CSE' },

      // Semester 4
      { subject: 'Database Management Systems', code: 'CS401', internal: 15, external: 20, total: 35, maxMarks: 100, grade: 'F', status: 'Fail', semester: 4, branch: 'CSE' }, // Backlog!
      { subject: 'Computer Networks', code: 'CS402', internal: 24, external: 51, total: 75, maxMarks: 100, grade: 'A', status: 'Pass', semester: 4, branch: 'CSE' }
    ];

    for (const r of results) {
      await prisma.$executeRawUnsafe(`
        INSERT INTO exam_results (id, subject, code, internal, external, total, max_marks, grade, status, semester, branch, created_at)
        VALUES (gen_random_uuid(), '${r.subject}', '${r.code}', ${r.internal}, ${r.external}, ${r.total}, ${r.maxMarks}, '${r.grade}', '${r.status}', ${r.semester}, '${r.branch}', NOW());
      `);
    }

    // 6. Seed Projects
    console.log("Seeding projects...");
    const projects = [
      // College Based - Mini Projects
      { title: 'E-Commerce Flutter Application', projectType: 'college_based', category: 'mini', domain: 'Mobile Apps', branch: 'CSE', description: 'Design and build a fully functional mobile commerce app with payment gateway, catalog, and cart integrations.', toolsRequired: 'Flutter, Dart, Firebase, Stripe API', difficulty: 'medium', rewardPoints: 400 },
      { title: 'Library Management Backend', projectType: 'college_based', category: 'mini', domain: 'Web Dev', branch: 'CSE', description: 'Build a secure RESTful API backend for managing library books issuance, returns, and penalities.', toolsRequired: 'Node.js, Express, MongoDB, JWT', difficulty: 'easy', rewardPoints: 300 },

      // College Based - Major Projects
      { title: 'AI-Powered Career Guidance Portal', projectType: 'college_based', category: 'major', domain: 'AI/ML', branch: 'CSE', description: 'Analyze student transcripts, resumes, and project logs to recommend optimal career tracks and matching placements.', toolsRequired: 'Python, FastAPI, Scikit-Learn, React, PostgreSQL', difficulty: 'hard', rewardPoints: 800 },
      { title: 'Blockchain Student Transcript Registry', projectType: 'college_based', category: 'major', domain: 'Cloud', branch: 'CSE', description: 'Create a decentralized secure student credentials/degrees repository to prevent fake certifications using blockchain ledger.', toolsRequired: 'Solidity, Ethereum, Web3.js, React, Infura', difficulty: 'hard', rewardPoints: 1000 },

      // Self Projects
      { title: 'Personal Portfolio Web App', projectType: 'self_project', category: null, domain: 'Web Dev', branch: null, description: 'Design and publish your responsive web portfolio showcasing projects, resume, and skills with contact forms.', toolsRequired: 'HTML5, Vanilla CSS, Javascript, GitHub Pages', difficulty: 'easy', rewardPoints: 200 },
      { title: 'Real-time Chat Application', projectType: 'self_project', category: null, domain: 'Mobile Apps', branch: null, description: 'Build a group and one-on-one messaging system utilizing persistent socket connections.', toolsRequired: 'Flutter, WebSockets, Node.js, Redis', difficulty: 'medium', rewardPoints: 500 },
      { title: 'Visual Object Detection Tool', projectType: 'self_project', category: null, domain: 'AI/ML', branch: null, description: 'Integrate pre-trained YOLO/ResNet models to identify objects dynamically from image/video streams.', toolsRequired: 'Python, OpenCV, TensorFlow/PyTorch', difficulty: 'hard', rewardPoints: 750 }
    ];

    for (const p of projects) {
      await prisma.$executeRawUnsafe(`
        INSERT INTO projects (id, title, project_type, category, domain, branch, description, tools_required, difficulty, reward_points, is_active, created_at)
        VALUES (
          gen_random_uuid(), '${p.title}', '${p.projectType}', 
          ${p.category ? `'${p.category}'` : 'NULL'}, 
          ${p.domain ? `'${p.domain}'` : 'NULL'}, 
          ${p.branch ? `'${p.branch}'` : 'NULL'}, 
          '${p.description}', '${p.toolsRequired}', '${p.difficulty}', ${p.rewardPoints}, true, NOW()
        );
      `);
    }

    // 7. Seed Notifications
    console.log("Seeding notifications...");
    const notifications = [
      { title: 'Semester 4 Mid-2 Results Published', body: 'Your results for Semester 4 are now available in your transcript. Go to results tab to view.', type: 'exam', link: '/results' },
      { title: 'AI-Powered Career Guidance Major Project Open', body: 'The final year major project statements are active. Review requirements and submit proposal.', type: 'project', link: '/projects' },
      { title: 'Google Summer of Code 2026 Live', body: 'Official organizations announced. Apply with proposal through GSoC dashboard.', type: 'internship', link: '/internships' },
      { title: 'Aptitude & Logical Reasoning material updated', body: 'Quantitative formulas sheet and logic tests uploaded under Exam Prep.', type: 'academic', link: '/academic-hub' }
    ];

    for (const n of notifications) {
      await prisma.$executeRawUnsafe(`
        INSERT INTO notifications (id, title, body, type, link, created_at)
        VALUES (gen_random_uuid(), '${n.title}', '${n.body}', '${n.type}', '${n.link}', NOW());
      `);
    }

    // 8. Run YouTube Courses Playlist script
    console.log("Running seed_youtube_courses.sql...");
    const sqlFilePath = path.join(__dirname, 'seed_youtube_courses.sql');
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');

    const cleanSql = sqlContent
      .split('\n')
      .map(line => line.replace(/--.*/g, "")) // strip single-line comments
      .join('\n')
      .replace(/\/\*[\s\S]*?\*\//g, ""); // strip multi-line comments

    const statements = [];
    let current = [];
    let inSingleQuote = false;
    let inDollarQuote = false;

    for (let i = 0; i < cleanSql.length; i++) {
      const char = cleanSql[i];
      const nextChar = cleanSql[i + 1] || '';

      if (char === '$' && nextChar === '$') {
        inDollarQuote = !inDollarQuote;
        current.push('$$');
        i++;
        continue;
      }

      if (char === "'" && !inDollarQuote) {
        if (nextChar === "'") {
          current.push("''");
          i++;
          continue;
        }
        inSingleQuote = !inSingleQuote;
        current.push("'");
        continue;
      }

      if (char === ';' && !inSingleQuote && !inDollarQuote) {
        statements.push(current.join(''));
        current = [];
      } else {
        current.push(char);
      }
    }

    if (current.length > 0) {
      statements.push(current.join(''));
    }

    const cleanStatements = statements
      .map(s => s.trim())
      .filter(s => s.length > 0);

    for (let i = 0; i < cleanStatements.length; i++) {
      const stmt = cleanStatements[i];
      try {
        await prisma.$executeRawUnsafe(stmt);
      } catch (err) {
        console.error(`Error executing course statement ${i + 1}:`, stmt.substring(0, 150) + "...");
        console.error(err.message || err);
        throw err;
      }
    }

    console.log("🎉 All premium features database tables seeded successfully!");
  } catch (error) {
    console.error("❌ Error seeding database:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
