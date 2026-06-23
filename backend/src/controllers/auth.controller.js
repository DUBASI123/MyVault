import bcrypt from 'bcryptjs';
import prisma from '../lib/prisma.js';
import { isEmailTarget, normalizePhone } from '../lib/phone.js';
import { signToken } from '../middleware/auth.middleware.js';
import { sendLiveOtpSms, sendLiveOtpEmail } from '../services/otp_delivery.service.js';
import { broadcastToUser } from '../services/socket_service.js';

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function studentResponse(student) {
  const { passwordHash, ...safe } = student;
  return safe;
}

async function findRecentVerifiedOtp(target, purpose) {
  return prisma.otpToken.findFirst({
    where: {
      target,
      purpose,
      used: true,
      expiresAt: { gt: new Date(Date.now() - 30 * 60 * 1000) },
    },
    orderBy: { createdAt: 'desc' },
  });
}

export async function register(req, res, next) {
  try {
    const {
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
      isMobileVerified = false,
      isEmailVerified = false,
    } = req.body;

    const normalizedMobile = normalizePhone(mobile);
    const normalizedEmail = String(email).trim().toLowerCase();

    let mobileOk = true;
    let emailOk = true;

    const passwordHash = await bcrypt.hash(password, 10);
    const student = await prisma.student.create({
      data: {
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
        isMobileVerified: true,
        isEmailVerified: true,
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

    const token = signToken({ sub: student.id, role: student.role });
    res.json({ token, student: studentResponse(student) });
  } catch (err) {
    next(err);
  }
}

export async function sendOtp(req, res, next) {
  try {
    const { target, purpose = 'reset' } = req.body;
    if (!target) return res.status(400).json({ error: 'Target required' });

    const normalized = isEmailTarget(target)
      ? String(target).trim().toLowerCase()
      : normalizePhone(target);

    const otp = generateOtp();
    if (process.env.NODE_ENV !== 'production') {
      console.log(`\n🔑 [DEV ONLY] OTP Code for ${normalized}: ${otp}\n`);
    }

    await prisma.otpToken.create({
      data: {
        target: normalized,
        code: otp,
        purpose,
        expiresAt: new Date(Date.now() + 10 * 60 * 1000),
      },
    });

    const isEmail = isEmailTarget(normalized);
    let delivery = null;

    try {
      delivery = isEmail
        ? await sendLiveOtpEmail(normalized, otp)
        : await sendLiveOtpSms(normalized, otp);
    } catch (deliveryErr) {
      if (process.env.NODE_ENV === 'production') throw deliveryErr;
      console.warn('OTP delivery fallback (dev):', deliveryErr.message);
    }

    res.json({
      message: 'OTP sent',
      target: normalized,
      channel: delivery?.channel,
      otpPreview: process.env.NODE_ENV !== 'production' ? otp : undefined,
    });
  } catch (err) {
    next(err);
  }
}

export async function verifyOtp(req, res, next) {
  try {
    const { target, otp, purpose = 'reset' } = req.body;
    if (!target || !otp) {
      return res.status(400).json({ error: 'Target and OTP required' });
    }

    const normalized = isEmailTarget(target)
      ? String(target).trim().toLowerCase()
      : normalizePhone(target);

    const record = await prisma.otpToken.findFirst({
      where: {
        target: normalized,
        code: otp,
        purpose,
        used: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!record) return res.status(400).json({ error: 'Invalid or expired OTP' });

    if (purpose === 'reset') {
      return res.json({ verified: true, target: normalized });
    }

    await prisma.otpToken.update({
      where: { id: record.id },
      data: { used: true },
    });

    const student = await prisma.student.findFirst({
      where: isEmailTarget(normalized)
        ? { email: normalized }
        : { mobile: normalized },
    });

    if (student) {
      await prisma.student.update({
        where: { id: student.id },
        data: isEmailTarget(normalized)
          ? { isEmailVerified: true }
          : { isMobileVerified: true },
      });
    }

    res.json({ verified: true, target: normalized });
  } catch (err) {
    next(err);
  }
}

export async function resetPassword(req, res, next) {
  try {
    const { identifier, otp, newPassword, target } = req.body;
    if (!identifier || !otp || !newPassword) {
      return res.status(400).json({ error: 'Identifier, OTP, and new password required' });
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
    });
    if (!student) return res.status(404).json({ error: 'User not found' });

    const otpTarget = target
      ? (isEmailTarget(target) ? String(target).trim().toLowerCase() : normalizePhone(target))
      : student.email;

    const record = await prisma.otpToken.findFirst({
      where: {
        target: otpTarget,
        code: otp,
        purpose: 'reset',
        used: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });
    if (!record) return res.status(400).json({ error: 'Invalid or expired OTP' });

    await prisma.student.update({
      where: { id: student.id },
      data: { passwordHash: await bcrypt.hash(newPassword, 10) },
    });
    await prisma.otpToken.update({ where: { id: record.id }, data: { used: true } });

    res.json({ message: 'Password updated' });
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

    const whereClause = { status: 'PENDING_APPROVAL' };
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
      data: { status: 'APPROVED' },
    });

    await prisma.notification.create({
      data: {
        title: 'Registration Approved',
        body: `Your registration for ${student.firstName} ${student.lastName} has been approved by your department admin.`,
        type: 'general',
      },
    });

    try {
      broadcastToUser(studentId, 'student_approved', { status: 'APPROVED' });
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

    const { studentId } = req.body;
    if (!studentId) return res.status(400).json({ error: 'studentId required' });

    const student = await prisma.student.update({
      where: { id: studentId },
      data: { status: 'REJECTED' },
    });

    await prisma.notification.create({
      data: {
        title: 'Registration Rejected',
        body: `Your registration for ${student.firstName} ${student.lastName} was rejected by your department admin.`,
        type: 'general',
      },
    });

    try {
      broadcastToUser(studentId, 'student_rejected', { status: 'REJECTED' });
    } catch (_) {}

    res.json({ message: 'Student rejected successfully', studentId });
  } catch (err) {
    next(err);
  }
}

