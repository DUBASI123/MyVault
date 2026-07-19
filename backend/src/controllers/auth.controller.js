import bcrypt from 'bcryptjs';
import { createClient } from '@supabase/supabase-js';
import prisma from '../lib/prisma.js';
import { normalizePhone } from '../lib/phone.js';
import { signToken } from '../middleware/auth.middleware.js';
import { broadcastToUser } from '../services/socket_service.js';
import { uploadBuffer } from '../services/cloudinary.service.js';
import { linkAndConfirmPhone } from '../services/supabaseAdmin.service.js';
import { createOtp, verifyOtp } from '../utils/otp.js';

// ─────────────────────────────────────────────────────────────────────────
// Login OTP now uses the SAME delivery path as registration: Supabase Auth's
// built-in phone OTP (Authentication → Providers → Phone in the Supabase
// dashboard), instead of the old custom sendLiveOtpSms/Twilio path.
//
// New flow:
//   1. POST /auth/login          — validates identifier+password only.
//                                   Returns requiresOtp + the student's full
//                                   mobile (E.164) so the Flutter client can
//                                   call Supabase's signInWithOtp directly.
//   2. Flutter calls Supabase signInWithOtp(phone) — Supabase sends the SMS.
//   3. Flutter calls Supabase verifyOTP(phone, token) — Supabase confirms it
//      and returns a session/access token.
//   4. POST /auth/login/confirm-otp — Flutter sends { studentId, accessToken }.
//      This backend verifies that access token against Supabase (via the
//      admin client below) and confirms the verified phone matches the
//      student's mobile on file, THEN issues this app's own JWT.
//
// The old otpCode/otpExpiresAt columns and the custom SMS delivery service
// are no longer used by login. They can be dropped in a future migration
// once you confirm nothing else reads them.
// ─────────────────────────────────────────────────────────────────────────

const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
);

function studentResponse(student) {
  const { passwordHash, otpCode, otpExpiresAt, ...safe } = student;
  return safe;
}

function maskMobile(mobile) {
  return mobile.replace(/(\d{2})\d+(\d{2})$/, '$1******$2');
}

/** Digits-only comparison so "+919876543210" and "919876543210" both match. */
function digitsOnly(v) {
  return (v || '').replace(/\D/g, '');
}

export async function register(req, res, next) {
  try {
    const {
      id,
      firstName,
      lastName,
      fullNameAadhar,
      mobile,
      email,
      password,
      hallTicket,
      universityId,
      collegeId,
      course,
      branch,
      semester,
      yearOfStudy,
      passingYear,
      gender,
      state,
      profilePicUrl,
      idCardUrl,
    } = req.body;

    const normalizedMobile = normalizePhone(mobile);
    const normalizedEmail = String(email).trim().toLowerCase();

    const passwordHash = await bcrypt.hash(password, 10);
    const student = await prisma.student.create({
      data: {
        id: id || undefined,
        firstName,
        lastName,
        fullNameAadhar,
        mobile: normalizedMobile,
        email: normalizedEmail,
        passwordHash,
        hallTicket,
        universityId: universityId || null,
        collegeId: collegeId || null,
        course,
        branch,
        semester: semester ?? 1,
        yearOfStudy: yearOfStudy ?? 1,
        passingYear,
        gender,
        state,
        profilePicUrl: profilePicUrl || null,
        idCardUrl: idCardUrl || null,
        isMobileVerified: true,
        isEmailVerified: true,
        verificationStatus: 'Approved',
        isVerified: true,
      },
      include: { university: true, college: true },
    });

    res.status(201).json({
      message: 'Registered successfully.',
      student: studentResponse(student),
    });
  } catch (err) {
    if (err.code === 'P2002') {
      return res.status(409).json({ error: 'Email, mobile, or hall ticket already registered' });
    }
    next(err);
  }
}

export async function login(req, res, next) {
  try {
    const { identifier, password } = req.body;
    if (!identifier || !password) {
      return res.status(400).json({ error: 'Identifier and password required' });
    }

    const id = String(identifier).trim();
    const mobileGuess = id.includes('@') ? null : normalizePhone(id);

    const student = await prisma.student.findFirst({
      where: {
        OR: [
          { email: id.toLowerCase() },
          { hallTicket: id },
          { mobile: id },
          ...(mobileGuess ? [{ mobile: mobileGuess }] : []),
        ],
      },
      include: { university: true, college: true },
    });

    if (!student) return res.status(401).json({ error: 'Invalid credentials' });

    const valid = await bcrypt.compare(password, student.passwordHash);
    if (!valid) return res.status(401).json({ error: 'Invalid credentials' });

    if (!student.mobile) {
      return res.status(400).json({ error: 'No mobile number on file for OTP verification' });
    }

    await createOtp(student.mobile, 'SMS', 'login');

    res.json({
      requiresOtp: true,
      studentId: student.id,
      maskedMobile: maskMobile(student.mobile),
    });
  } catch (err) {
    next(err);
  }
}

export async function verifyLoginOtp(req, res, next) {
  try {
    const { studentId, otp } = req.body;
    if (!studentId || !otp) {
      return res.status(400).json({ error: 'studentId and otp are required' });
    }

    const student = await prisma.student.findUnique({
      where: { id: studentId },
      include: { university: true, college: true },
    });
    if (!student) return res.status(404).json({ error: 'Student not found' });

    await verifyOtp(student.mobile, 'login', otp);

    const token = signToken({ sub: student.id, role: student.role });
    res.json({ token, student: studentResponse(student) });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}

export async function resendLoginOtp(req, res, next) {
  try {
    const { studentId } = req.body;
    if (!studentId) return res.status(400).json({ error: 'studentId is required' });

    const student = await prisma.student.findUnique({
      where: { id: studentId }
    });
    if (!student) return res.status(404).json({ error: 'Student not found' });

    await createOtp(student.mobile, 'SMS', 'login');
    res.json({ message: 'OTP resent successfully' });
  } catch (err) {
    next(err);
  }
}



export async function getMe(req, res, next) {
  try {
    const student = await prisma.student.findUnique({
      where: { id: req.user.sub },
      include: { university: true, college: true },
    });
    if (!student) return res.status(404).json({ error: 'Student not found' });
    res.json({ student: studentResponse(student) });
  } catch (err) {
    next(err);
  }
}

export async function getPendingStudents(req, res, next) {
  try {
    const admin = await prisma.student.findUnique({ where: { id: req.user.sub } });
    if (!admin || !['dept_admin', 'college_admin', 'super_admin'].includes(admin.role)) {
      return res.status(403).json({ error: 'Unauthorized role' });
    }

    const whereClause = { verificationStatus: 'Pending' };
    if (admin.role === 'dept_admin') {
      whereClause.collegeId = admin.collegeId;
      whereClause.branch = admin.branch;
    } else if (admin.role === 'college_admin') {
      whereClause.collegeId = admin.collegeId;
    }

    const pending = await prisma.student.findMany({
      where: whereClause,
      orderBy: { createdAt: 'desc' },
      include: { university: true, college: true },
    });
    res.json(pending);
  } catch (err) {
    next(err);
  }
}

export async function approveStudent(req, res, next) {
  try {
    const admin = await prisma.student.findUnique({ where: { id: req.user.sub } });
    if (!admin || !['dept_admin', 'college_admin', 'super_admin'].includes(admin.role)) {
      return res.status(403).json({ error: 'Unauthorized role' });
    }

    const { studentId } = req.body;
    if (!studentId) return res.status(400).json({ error: 'studentId required' });

    const student = await prisma.student.update({
      where: { id: studentId },
      data: {
        verificationStatus: 'Approved',
        isVerified: true,
        rejectionReason: null,
      },
    });

    await prisma.notification.create({
      data: {
        title: 'Registration Approved',
        body: `Your registration for ${student.firstName} ${student.lastName} has been approved by your department admin.`,
        type: 'general',
      },
    });

    try {
      broadcastToUser(studentId, 'student_approved', {
        status: 'APPROVED',
        verificationStatus: 'Approved',
        isVerified: true,
      });
    } catch (_) {}

    res.json({ message: 'Student approved successfully', studentId });
  } catch (err) {
    next(err);
  }
}

export async function rejectStudent(req, res, next) {
  try {
    const admin = await prisma.student.findUnique({ where: { id: req.user.sub } });
    if (!admin || !['dept_admin', 'college_admin', 'super_admin'].includes(admin.role)) {
      return res.status(403).json({ error: 'Unauthorized role' });
    }

    const { studentId, reason } = req.body;
    if (!studentId) return res.status(400).json({ error: 'studentId required' });

    const student = await prisma.student.update({
      where: { id: studentId },
      data: {
        verificationStatus: 'Rejected',
        isVerified: false,
        rejectionReason: reason || 'Rejected by administrator',
      },
    });

    await prisma.notification.create({
      data: {
        title: 'Registration Rejected',
        body: `Your registration for ${student.firstName} ${student.lastName} was rejected by your department admin.`,
        type: 'general',
      },
    });

    try {
      broadcastToUser(studentId, 'student_rejected', {
        status: 'REJECTED',
        verificationStatus: 'Rejected',
        isVerified: false,
        rejectionReason: reason || 'Rejected by administrator',
      });
    } catch (_) {}

    res.json({ message: 'Student rejected successfully', studentId });
  } catch (err) {
    next(err);
  }
}

export async function uploadFile(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    const secureUrl = await uploadBuffer(req.file.buffer, req.file.originalname);
    res.json({ url: secureUrl });
  } catch (err) {
    next(err);
  }
}

export async function linkPhone(req, res, next) {
  try {
    const { userId, phone } = req.body;
    if (!userId || !phone) {
      return res.status(400).json({ error: 'userId and phone are required' });
    }

    const normalized = normalizePhone(phone);
    const e164 = normalized.startsWith('+') ? normalized : `+91${normalized.replace(/^0+/, '')}`;

    const user = await linkAndConfirmPhone(userId, e164);
    res.json({ message: 'Phone linked and confirmed', phone: user.phone });
  } catch (err) {
    next(err);
  }
}
