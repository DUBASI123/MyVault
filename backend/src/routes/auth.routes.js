import { Router } from 'express';
import { body } from 'express-validator';
import rateLimit from 'express-rate-limit';
import { createOtp, verifyOtp as verifyNewOtp } from '../utils/otp.js';
import {
  getMe,
  login,
  register,
  resetPassword,
  sendOtp,
  verifyOtp,
  getPendingStudents,
  approveStudent,
  rejectStudent,
  uploadFile,
} from '../controllers/auth.controller.js';
import { authMiddleware } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.js';
import multer from 'multer';

const upload = multer({ storage: multer.memoryStorage() });

const otpSendLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 3,
  message: { error: 'Too many OTP requests. Please try again after 10 minutes.' },
  keyGenerator: (req) => req.body.identifier || req.ip,
  standardHeaders: true,
  legacyHeaders: false,
});

const router = Router();

router.post(
  '/register',
  [
    body('firstName').notEmpty().withMessage('First name required'),
    body('lastName').notEmpty().withMessage('Last name required'),
    body('fullNameAadhar').notEmpty().withMessage('Aadhar name required'),
    body('email').isEmail().withMessage('Valid email required'),
    body('password').isLength({ min: 6 }).withMessage('Password min 6 characters'),
    body('mobile').notEmpty().withMessage('Mobile required'),
    body('hallTicket').notEmpty().withMessage('Hall ticket required'),
    body('course').notEmpty().withMessage('Course required'),
    body('branch').notEmpty().withMessage('Branch required'),
  ],
  validate,
  register,
);

router.post(
  '/login',
  [
    body('identifier').notEmpty().withMessage('Identifier required'),
    body('password').notEmpty().withMessage('Password required'),
  ],
  validate,
  login,
);

router.post(
  '/send-otp',
  [body('target').notEmpty().withMessage('Target required')],
  validate,
  sendOtp,
);

router.post(
  '/verify-otp',
  [
    body('target').notEmpty().withMessage('Target required'),
    body('otp').isLength({ min: 6, max: 6 }).withMessage('6-digit OTP required'),
  ],
  validate,
  verifyOtp,
);

router.post(
  '/reset-password',
  [
    body('identifier').notEmpty().withMessage('Identifier required'),
    body('otp').isLength({ min: 6, max: 6 }).withMessage('6-digit OTP required'),
    body('newPassword').isLength({ min: 6 }).withMessage('Password min 6 characters'),
  ],
  validate,
  resetPassword,
);

router.get('/me', authMiddleware, getMe);

router.get('/admin/pending-students', authMiddleware, getPendingStudents);
router.post('/admin/approve-student', authMiddleware, approveStudent);
router.post('/admin/reject-student', authMiddleware, rejectStudent);

router.post('/upload', upload.single('file'), uploadFile);

router.post(
  '/otp/send',
  otpSendLimiter,
  [
    body('identifier').notEmpty().withMessage('Identifier (phone/email) required'),
    body('channel').isIn(['SMS', 'EMAIL']).withMessage('Valid channel (SMS/EMAIL) required'),
    body('purpose').isIn(['REGISTER', 'LOGIN', 'PASSWORD_RESET']).withMessage('Valid purpose required'),
  ],
  validate,
  async (req, res, next) => {
    try {
      const { identifier, channel, purpose } = req.body;
      const otp = await createOtp(identifier, channel, purpose);
      res.json({
        message: 'OTP sent successfully',
        identifier,
        channel,
        otpPreview: process.env.NODE_ENV !== 'production' ? otp : undefined
      });
    } catch (err) {
      next(err);
    }
  }
);

router.post(
  '/otp/verify',
  [
    body('identifier').notEmpty().withMessage('Identifier (phone/email) required'),
    body('purpose').isIn(['REGISTER', 'LOGIN', 'PASSWORD_RESET']).withMessage('Valid purpose required'),
    body('otp').isLength({ min: 6, max: 6 }).withMessage('6-digit OTP required'),
  ],
  validate,
  async (req, res, next) => {
    try {
      const { identifier, purpose, otp } = req.body;
      await verifyNewOtp(identifier, purpose, otp);
      res.json({ verified: true, identifier, purpose });
    } catch (err) {
      res.status(400).json({ error: err.message || 'Verification failed' });
    }
  }
);

export default router;
