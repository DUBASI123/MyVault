import { PrismaClient } from '@prisma/client';
import { linkAndConfirmPhone } from '../src/services/supabaseAdmin.service.js';
import dotenv from 'dotenv';

dotenv.config();

const prisma = new PrismaClient();

async function run() {
  console.log('Starting phone identity backfill process...');
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    console.error('❌ Error: SUPABASE_SERVICE_ROLE_KEY is missing in your environment variables.');
    process.exit(1);
  }

  try {
    const students = await prisma.student.findMany({
      select: { id: true, email: true, mobile: true }
    });

    console.log(`Found ${students.length} students in the database.`);

    for (const student of students) {
      if (!student.mobile) {
        console.log(`Skipping student ${student.email} (no mobile number).`);
        continue;
      }

      const raw = student.mobile.trim();
      const digits = raw.replace(/\D/g, '');
      const e164 = raw.startsWith('+') ? raw : `+91${digits.replace(/^0+/, '')}`;

      console.log(`Linking phone ${e164} for user ID ${student.id} (${student.email})...`);
      try {
        await linkAndConfirmPhone(student.id, e164);
        console.log(`✅ Success for ${student.email}`);
      } catch (err) {
        console.error(`❌ Failed to link phone for ${student.email}:`, err.message);
      }
    }

    console.log('Phone identity backfill process completed!');
  } catch (err) {
    console.error('❌ Backfill process crashed:', err);
  } finally {
    await prisma.$disconnect();
  }
}

run();
