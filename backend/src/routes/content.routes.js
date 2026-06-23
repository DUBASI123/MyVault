import { Router } from 'express';
import prisma from '../lib/prisma.js';

const router = Router();

router.get('/ticker', async (_req, res, next) => {
  try {
    const items = await prisma.notification.findMany({
      orderBy: { createdAt: 'desc' },
      take: 5,
    });
    const ticker = items.length
      ? items.map((n) => `🔔 ${n.title}`).join(' | ')
      : 'Welcome to My Vault — your student platform';
    res.json({ ticker });
  } catch (err) {
    next(err);
  }
});

router.get('/notifications', async (_req, res, next) => {
  try {
    const data = await prisma.notification.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.get('/results', async (req, res, next) => {
  try {
    const { branch, semester } = req.query;
    const data = await prisma.examResult.findMany({
      where: {
        ...(branch ? { branch: String(branch) } : {}),
        ...(semester ? { semester: Number(semester) } : {}),
      },
      orderBy: { subject: 'asc' },
    });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.get('/internships', async (req, res, next) => {
  try {
    const { type } = req.query;
    const data = await prisma.internship.findMany({
      where: type ? { type: String(type) } : undefined,
      orderBy: { createdAt: 'desc' },
    });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

export default router;
