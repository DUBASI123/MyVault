import { PrismaClient } from '@prisma/client';
import fs from 'fs';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding My Vault database...');

  const universities = [
    { id: '1', name: 'JNTUH Affiliated', code: 'JNTUH', state: 'Telangana' },
    { id: '2', name: 'Osmania University Affiliated', code: 'OU', state: 'Telangana' },
    { id: '3', name: 'Kakatiya University Affiliated', code: 'KU', state: 'Telangana' },
    { id: '4', name: 'RGUKT Campuses', code: 'RGUKT', state: 'Telangana' },
    { id: '5', name: 'Government Engineering Colleges', code: 'Govt', state: 'Telangana' },
    { id: '6', name: 'National Institutes & Private Universities', code: 'National', state: 'Telangana' },
  ];

  for (const uni of universities) {
    await prisma.university.upsert({
      where: { code: uni.code },
      create: uni,
      update: { name: uni.name, state: uni.state },
    });
  }

  const colleges = JSON.parse(
    fs.readFileSync(new URL('colleges.json', import.meta.url), 'utf8')
  );

  for (const college of colleges) {
    await prisma.college.upsert({
      where: { code: college.code },
      create: college,
      update: {
        name: college.name,
        universityId: college.universityId,
        district: college.district,
        type: college.type,
        state: college.state,
      },
    });
  }

  const subjects = [
    { name: 'Data Structures', code: 'CS201', branch: 'CSE', semester: 3 },
    { name: 'Operating Systems', code: 'CS301', branch: 'CSE', semester: 5 },
    { name: 'Database Management', code: 'CS302', branch: 'CSE', semester: 5 },
    { name: 'Computer Networks', code: 'CS401', branch: 'CSE', semester: 7 },
  ];

  for (const subject of subjects) {
    const existing = await prisma.subject.findFirst({
      where: { code: subject.code, branch: subject.branch, semester: subject.semester },
    });
    if (!existing) {
      await prisma.subject.create({ data: subject });
    }
  }

  const notifications = [
    { title: 'TSPSC Group I Notification', body: 'Applications open until Dec 31. Apply at tspsc.gov.in', type: 'exam' },
    { title: 'JNTUH Mid-2 Exams', body: 'Mid semester exams begin Dec 15. Check hall tickets.', type: 'exam' },
    { title: 'Infosys Internship Open', body: 'Software Engineer Intern — apply before Dec 31.', type: 'internship' },
    { title: 'GATE 2025 Registration', body: 'GATE registration is now open at gate2025.iisc.ac.in', type: 'exam' },
  ];

  for (const n of notifications) {
    const existing = await prisma.notification.findFirst({ where: { title: n.title } });
    if (!existing) await prisma.notification.create({ data: n });
  }

  const results = [
    { subject: 'Mathematics - I', code: 'M101', internal: 28, external: 62, total: 90, maxMarks: 100, grade: 'A+', status: 'Pass', semester: 1, branch: 'CSE' },
    { subject: 'Data Structures', code: 'CS201', internal: 20, external: 35, total: 55, maxMarks: 100, grade: 'C', status: 'Pass', semester: 3, branch: 'CSE' },
    { subject: 'DBMS', code: 'CS301', internal: 18, external: 24, total: 42, maxMarks: 100, grade: 'F', status: 'Fail', semester: 5, branch: 'CSE' },
  ];

  for (const r of results) {
    const existing = await prisma.examResult.findFirst({ where: { code: r.code, branch: r.branch } });
    if (!existing) await prisma.examResult.create({ data: r });
  }

  const internships = [
    { company: 'Infosys', role: 'Software Engineer Intern', type: 'IT', domain: 'Java / Python', stipend: '₹15,000/month', duration: '6 months', deadline: '2024-12-31', applyLink: 'https://infosys.com', logo: '🏢', status: 'Open' },
    { company: 'TCS', role: 'IT Intern - Digital', type: 'IT', domain: 'Web Development', stipend: '₹12,000/month', duration: '3 months', deadline: '2024-12-15', applyLink: 'https://tcs.com', logo: '🏢', status: 'Open' },
    { company: 'BHEL', role: 'Mechanical Engineering Intern', type: 'core', domain: 'Mechanical', stipend: '₹10,000/month', duration: '2 months', deadline: '2024-11-30', applyLink: 'https://bhel.com', logo: '🏭', status: 'Closing Soon' },
    { company: 'AWS', role: 'Cloud Tools Intern', type: 'tools', domain: 'Cloud Computing', stipend: '₹20,000/month', duration: '6 months', deadline: '2024-12-25', applyLink: 'https://aws.amazon.com', logo: '☁️', status: 'Open' },
  ];

  for (const i of internships) {
    const existing = await prisma.internship.findFirst({ where: { company: i.company, role: i.role } });
    if (!existing) await prisma.internship.create({ data: i });
  }

  console.log('Seed complete.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
