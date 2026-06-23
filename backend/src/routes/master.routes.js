import { Router } from 'express';
import prisma from '../lib/prisma.js';

const router = Router();

router.get('/universities', async (_req, res, next) => {
  try {
    const data = await prisma.university.findMany({ orderBy: { name: 'asc' } });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.get('/colleges', async (req, res, next) => {
  try {
    const { universityId } = req.query;
    const data = await prisma.college.findMany({
      where: universityId ? { universityId: String(universityId) } : undefined,
      orderBy: { name: 'asc' },
    });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

export default router;
