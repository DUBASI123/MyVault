import { Router } from 'express';
import { body } from 'express-validator';
import {
  getMe,
  login,
  register,
  confirmLoginOtp,
  getPendingStudents,
  approveStudent,
  rejectStudent,
  uploadFile,
  linkPhone,
} from '../controllers/auth.controller.js';
import { authMiddleware } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.js';
import multer from 'multer';

const upload = multer({ storage: multer.memoryStorage() });

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

router.post('/login/confirm-otp', confirmLoginOtp);

router.get('/me', authMiddleware, getMe);

router.get('/admin/pending-students', authMiddleware, getPendingStudents);
router.post('/admin/approve-student', authMiddleware, approveStudent);
router.post('/admin/reject-student', authMiddleware, rejectStudent);

router.post('/upload', upload.single('file'), uploadFile);
router.post('/auth/link-phone', linkPhone);

export default router;
