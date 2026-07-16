/**
 * scripts/backfill-phone-identities.js
 *
 * One-off script: links + auto-confirms each existing student's mobile
 * number as a Supabase Auth identity, so mobile OTP (Forgot Password)
 * works for accounts that were registered BEFORE phone-linking was added
 * to the registration flow.
 *
 * Usage:
 *   node scripts/backfill-phone-identities.js
 *
 * Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in your backend .env.
 * Safe to re-run — skips students whose phone is already linked/confirmed.
 */

import 'dotenv/config';
import prisma from '../src/lib/prisma.js';
import { linkAndConfirmPhone } from '../src/services/supabaseAdmin.service.js';
import { normalizePhone } from '../src/lib/phone.js';

function toE164(mobile) {
  const normalized = normalizePhone(mobile);
  if (normalized.startsWith('+')) return normalized;
  return `+91${normalized.replace(/^0+/, '')}`;
}

async function run() {
  const students = await prisma.student.findMany({
    select: { id: true, mobile: true, email: true, firstName: true, lastName: true },
  });

  console.log(`Found ${students.length} students. Starting backfill...\n`);

  let success = 0;
  let skipped = 0;
  let failed = 0;

  for (const student of students) {
    if (!student.mobile) {
      console.log(`⏭  Skipping ${student.firstName} ${student.lastName} — no mobile on file`);
      skipped++;
      continue;
    }

    try {
      const e164 = toE164(student.mobile);
      await linkAndConfirmPhone(student.id, e164);
      console.log(`✅ Linked ${e164} for ${student.firstName} ${student.lastName} (${student.email})`);
      success++;
    } catch (err) {
      console.error(`❌ Failed for ${student.firstName} ${student.lastName} (${student.email}): ${err.message}`);
      failed++;
    }

    // Gentle pacing to avoid hammering Supabase's admin API on large tables
    await new Promise((r) => setTimeout(r, 150));
  }

  console.log(`\nDone. Linked: ${success}, Skipped: ${skipped}, Failed: ${failed}`);
  process.exit(0);
}

run().catch((err) => {
  console.error('Backfill script crashed:', err);
  process.exit(1);
});
