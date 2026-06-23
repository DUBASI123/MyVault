import { Router } from 'express';
import prisma from '../lib/prisma.js';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/subjects', async (req, res, next) => {
  try {
    const { branch, semester } = req.query;
    const data = await prisma.subject.findMany({
      where: {
        branch: String(branch),
        semester: Number(semester),
      },
      orderBy: { name: 'asc' },
    });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.get('/contents/:subjectId', async (req, res, next) => {
  try {
    const { contentType } = req.query;
    const data = await prisma.academicContent.findMany({
      where: {
        subjectId: req.params.subjectId,
        ...(contentType && contentType !== 'all'
          ? { contentType: String(contentType) }
          : {}),
      },
      orderBy: { createdAt: 'desc' },
    });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.post('/contents', authMiddleware, async (req, res, next) => {
  try {
    const content = await prisma.academicContent.create({ data: req.body });
    try {
      const { broadcastGlobal } = await import('../services/socket_service.js');
      broadcastGlobal('content_changed', { action: 'create', subjectId: content.subjectId });
    } catch (_) {}
    res.status(201).json(content);
  } catch (err) {
    next(err);
  }
});

router.put('/contents/:id', authMiddleware, async (req, res, next) => {
  try {
    const { id } = req.params;
    const content = await prisma.academicContent.update({
      where: { id },
      data: req.body,
    });
    try {
      const { broadcastGlobal } = await import('../services/socket_service.js');
      broadcastGlobal('content_changed', { action: 'update', subjectId: content.subjectId });
    } catch (_) {}
    res.json(content);
  } catch (err) {
    next(err);
  }
});

router.delete('/contents/:id', authMiddleware, async (req, res, next) => {
  try {
    const { id } = req.params;
    const content = await prisma.academicContent.delete({
      where: { id },
    });
    try {
      const { broadcastGlobal } = await import('../services/socket_service.js');
      broadcastGlobal('content_changed', { action: 'delete', subjectId: content.subjectId });
    } catch (_) {}
    res.json({ message: 'Content deleted successfully', id });
  } catch (err) {
    next(err);
  }
});

export default router;
