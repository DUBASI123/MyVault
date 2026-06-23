import prisma from '../lib/prisma.js';

function otpToolsStatus() {
  const sms =
    Boolean(process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) ||
    Boolean(process.env.FAST2SMS_API_KEY);
  const email =
    Boolean(process.env.SMTP_HOST && process.env.SMTP_USER) ||
    Boolean(process.env.SENDGRID_API_KEY);
  return {
    sms: { configured: sms, provider: process.env.FAST2SMS_API_KEY ? 'fast2sms' : process.env.TWILIO_ACCOUNT_SID ? 'twilio' : null },
    email: { configured: email, provider: process.env.SENDGRID_API_KEY ? 'sendgrid' : (Boolean(process.env.SMTP_HOST && process.env.SMTP_USER) ? 'smtp' : null) },
    devPreview: process.env.NODE_ENV !== 'production',
  };
}

export async function getLiveStatus() {
  const tools = {
    database: { ok: false, provider: 'postgresql' },
    auth: { ok: true, endpoints: ['register', 'login', 'send-otp', 'verify-otp', 'reset-password', 'me'] },
    master: { ok: true, endpoints: ['universities', 'colleges'] },
    academic: { ok: true, endpoints: ['subjects', 'contents', 'upload'] },
    content: { ok: true, endpoints: ['ticker', 'notifications', 'results', 'internships'] },
    otp: otpToolsStatus(),
  };

  try {
    const [universities, colleges, subjects, notifications, results, internships] =
      await Promise.all([
        prisma.university.count(),
        prisma.college.count(),
        prisma.subject.count(),
        prisma.notification.count(),
        prisma.examResult.count(),
        prisma.internship.count(),
      ]);

    tools.database = {
      ok: true,
      provider: process.env.DATABASE_URL?.startsWith('file:') ? 'sqlite' : 'postgresql',
      counts: { universities, colleges, subjects, notifications, results, internships },
    };
  } catch (err) {
    tools.database = { ok: false, error: err.message };
  }

  const allCoreOk =
    tools.database.ok &&
    tools.auth.ok &&
    tools.master.ok &&
    tools.academic.ok &&
    tools.content.ok;

  return {
    status: allCoreOk ? 'live' : 'degraded',
    service: 'my-vault-api',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    tools,
  };
}
