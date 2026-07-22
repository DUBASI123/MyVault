import { PrismaClient } from '@prisma/client';

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  const prisma = new PrismaClient({ datasources: { db: { url } } });

  try {
    console.log("=== APPLYING V1.1 SCHEMA (Bookmarks, Notifications, Device Tokens) ===");

    // 1. Bookmarks table
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS public.bookmarks (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        student_id TEXT NOT NULL,
        content_type TEXT NOT NULL CHECK (content_type IN (
          'note', 'video', 'lab_manual', 'syllabus', 'course', 'internship',
          'job', 'govt_job', 'project', 'study_material', 'certificate'
        )),
        content_id TEXT NOT NULL,
        metadata JSONB DEFAULT '{}'::jsonb,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (student_id, content_type, content_id)
      );
    `);

    await prisma.$executeRawUnsafe(`
      CREATE INDEX IF NOT EXISTS idx_bookmarks_student ON public.bookmarks(student_id, created_at DESC);
    `);

    // 2. Notifications table alterations
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS public.notifications (
        id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await prisma.$executeRawUnsafe(`ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS student_id TEXT;`);
    await prisma.$executeRawUnsafe(`ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'general';`);
    await prisma.$executeRawUnsafe(`ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS deep_link TEXT;`);
    await prisma.$executeRawUnsafe(`ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS is_broadcast BOOLEAN DEFAULT FALSE;`);
    await prisma.$executeRawUnsafe(`ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS sent_at TIMESTAMPTZ DEFAULT NOW();`);

    await prisma.$executeRawUnsafe(`
      CREATE INDEX IF NOT EXISTS idx_notifications_student ON public.notifications(student_id, sent_at DESC);
    `);

    await prisma.$executeRawUnsafe(`
      CREATE INDEX IF NOT EXISTS idx_notifications_broadcast ON public.notifications(is_broadcast, sent_at DESC);
    `);

    // 3. Notification reads table
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS public.notification_reads (
        student_id TEXT NOT NULL,
        notification_id TEXT NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
        read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        PRIMARY KEY (student_id, notification_id)
      );
    `);

    // 4. Device Tokens table
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS public.device_tokens (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        student_id TEXT NOT NULL,
        fcm_token TEXT NOT NULL,
        platform TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (student_id, fcm_token)
      );
    `);

    console.log("✅ V1.1 Tables and Schema applied successfully!");
  } catch (err) {
    console.error("Error applying V1.1 Schema:", err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
