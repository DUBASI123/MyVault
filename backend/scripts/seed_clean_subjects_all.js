import { PrismaClient } from '@prisma/client';

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  const prisma = new PrismaClient({
    datasources: { db: { url } }
  });

  try {
    console.log("Starting comprehensive subjects database cleanup & seeding...");

    // 1. Delete any garbage/junk entries matching pattern or short random strings
    await prisma.$executeRawUnsafe(`
      DELETE FROM subjects 
      WHERE name ~* '^[a-z0-9]{3,7}$' 
        AND name !~* '^(java|python|dsa|gate|apti|math|physics|chemistry|dbms)$';
    `);

    // Clean exact junk names
    const junkNames = ['WSN009', 'LDIC', 'jgv0', 'gvuygb', 'dld90'];
    for (const j of junkNames) {
      await prisma.$executeRawUnsafe(`DELETE FROM subjects WHERE LOWER(name) = LOWER('${j}') OR LOWER(code) = LOWER('${j}');`);
    }

    // Standard subjects per branch and semester
    const branchSubjects = {
      ECE: {
        1: [
          { name: 'Mathematics - I', code: 'M101' },
          { name: 'Engineering Physics', code: 'EP102' },
          { name: 'Basic Electrical Engineering', code: 'BEE103' },
          { name: 'C Programming & Data Structures', code: 'CPDS104' },
          { name: 'Engineering Graphics & Design', code: 'EGD105' },
        ],
        2: [
          { name: 'Mathematics - II', code: 'M201' },
          { name: 'Engineering Chemistry', code: 'EC202' },
          { name: 'Electronic Devices & Circuits', code: 'EDC203' },
          { name: 'Network Analysis & Synthesis', code: 'NAS204' },
          { name: 'English & Communication Skills', code: 'ECS205' },
        ],
        3: [
          { name: 'Analog Circuits', code: 'AC301' },
          { name: 'Signals & Systems', code: 'SS302' },
          { name: 'Digital Electronics & Logic Design', code: 'DELD303' },
          { name: 'Electromagnetic Fields & Waves', code: 'EMFW304' },
          { name: 'Probability Theory & Stochastic Processes', code: 'PTSP305' },
        ],
        4: [
          { name: 'Linear Integrated Circuits', code: 'LIC401' },
          { name: 'Analog Communication', code: 'AC402' },
          { name: 'Microprocessors & Microcontrollers', code: 'MPMC403' },
          { name: 'Control Systems', code: 'CS404' },
          { name: 'Computer Architecture & Organization', code: 'CAO405' },
        ],
        5: [
          { name: 'Digital Communication', code: 'DC501' },
          { name: 'Digital Signal Processing', code: 'DSP502' },
          { name: 'VLSI Design', code: 'VLSI503' },
          { name: 'Antennas & Wave Propagation', code: 'AWP504' },
          { name: 'Managerial Economics & Financial Analysis', code: 'MEFA505' },
        ],
        6: [
          { name: 'Microwave Engineering', code: 'MWE601' },
          { name: 'Embedded Systems', code: 'ES602' },
          { name: 'Wireless Communication & Networks', code: 'WCN603' },
          { name: 'Optical Communication', code: 'OC604' },
          { name: 'Information Theory & Coding', code: 'ITC605' },
        ],
        7: [
          { name: 'Cellular & Mobile Communication', code: 'CMC701' },
          { name: 'Radar Systems & Satellite Communication', code: 'RSSC702' },
          { name: 'IoT Architecture & Protocols', code: 'IOT703' },
          { name: 'Robotics & Automation', code: 'RA704' },
        ],
        8: [
          { name: 'Deep Learning & Neural Networks', code: 'DLNN801' },
          { name: 'Major Project & Internship', code: 'PROJ802' },
        ]
      },
      CSE: {
        1: [
          { name: 'Mathematics - I', code: 'M101' },
          { name: 'Engineering Chemistry', code: 'EC102' },
          { name: 'Programming for Problem Solving in C', code: 'PPSC103' },
          { name: 'Basic Electrical & Electronics', code: 'BEE104' },
          { name: 'English Communication Skills', code: 'ECS105' },
        ],
        2: [
          { name: 'Mathematics - II', code: 'M201' },
          { name: 'Engineering Physics', code: 'EP202' },
          { name: 'Object Oriented Programming via C++', code: 'OOP203' },
          { name: 'Engineering Graphics', code: 'EG204' },
          { name: 'Environmental Science', code: 'EVS205' },
        ],
        3: [
          { name: 'Data Structures & Algorithms', code: 'DSA301' },
          { name: 'Discrete Mathematics', code: 'DM302' },
          { name: 'Digital Logic Design', code: 'DLD303' },
          { name: 'Object Oriented Programming via Java', code: 'OOPJ304' },
          { name: 'Computer Organization & Architecture', code: 'COA305' },
        ],
        4: [
          { name: 'Database Management Systems', code: 'DBMS401' },
          { name: 'Operating Systems', code: 'OS402' },
          { name: 'Design & Analysis of Algorithms', code: 'DAA403' },
          { name: 'Formal Languages & Automata Theory', code: 'FLAT404' },
          { name: 'Software Engineering', code: 'SE405' },
        ],
        5: [
          { name: 'Computer Networks', code: 'CN501' },
          { name: 'Compiler Design', code: 'CD502' },
          { name: 'Web Technologies & Development', code: 'WT503' },
          { name: 'Artificial Intelligence', code: 'AI504' },
          { name: 'Cyber Security & Cryptography', code: 'CSC505' },
        ],
        6: [
          { name: 'Machine Learning', code: 'ML601' },
          { name: 'Cloud Computing & DevOps', code: 'CCD602' },
          { name: 'Mobile Application Development', code: 'MAD603' },
          { name: 'Data Mining & Data Warehousing', code: 'DMDW604' },
        ],
        7: [
          { name: 'Big Data Analytics', code: 'BDA701' },
          { name: 'Distributed Systems', code: 'DS702' },
          { name: 'Natural Language Processing', code: 'NLP703' },
        ],
        8: [
          { name: 'Deep Learning & Neural Networks', code: 'DL801' },
          { name: 'Major Project Phase II', code: 'PROJ802' },
        ]
      }
    };

    for (const [branch, semesters] of Object.entries(branchSubjects)) {
      for (const [semStr, subjects] of Object.entries(semesters)) {
        const sem = parseInt(semStr, 10);
        for (const sub of subjects) {
          // Check if subject already exists
          const existing = await prisma.$queryRawUnsafe(`
            SELECT id FROM subjects 
            WHERE branch = '${branch}' AND semester = ${sem} AND LOWER(name) = LOWER('${sub.name.replace(/'/g, "''")}');
          `);
          if (existing.length === 0) {
            await prisma.$executeRawUnsafe(`
              INSERT INTO subjects (id, name, code, branch, semester, subject_type)
              VALUES (gen_random_uuid(), '${sub.name.replace(/'/g, "''")}', '${sub.code}', '${branch}', ${sem}, 'academic');
            `);
          }
        }
      }
    }

    console.log("Database subjects seeding & cleanup completed successfully!");
  } catch (err) {
    console.error("Error seeding clean subjects:", err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
