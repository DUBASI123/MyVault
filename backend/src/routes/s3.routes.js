import { Router } from 'express';
import { getPresignedViewUrl, getPresignedDownloadUrl } from '../lib/s3.js';

const router = Router();

/**
 * GET /api/s3/view/*
 * Returns a fresh pre-signed S3 URL for viewing a file.
 * The Flutter app calls this and opens the returned URL in a browser/PDF viewer.
 *
 * Example: GET /api/s3/view/study-materials/uuid-DLD_notes.pdf
 */
router.get('/view/*', async (req, res, next) => {
  try {
    const key = req.params[0];
    if (!key) return res.status(400).json({ error: 'File key is required' });

    const url = await getPresignedViewUrl(key);
    res.json({ url });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/s3/download/*
 * Returns a fresh pre-signed S3 URL that forces a file download.
 *
 * Example: GET /api/s3/download/study-materials/uuid-DLD_notes.pdf?fileName=DLD_notes.pdf
 */
router.get('/download/*', async (req, res, next) => {
  try {
    const key = req.params[0];
    const fileName = req.query.fileName || key.split('/').pop();
    if (!key) return res.status(400).json({ error: 'File key is required' });

    const url = await getPresignedDownloadUrl(key, fileName);
    res.json({ url });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/s3/redirect/*
 * Directly redirects to the pre-signed S3 URL (useful for direct links in apps).
 */
router.get('/redirect/*', async (req, res, next) => {
  try {
    const key = req.params[0];
    if (!key) return res.status(400).json({ error: 'File key is required' });

    const url = await getPresignedViewUrl(key);
    res.redirect(url);
  } catch (err) {
    next(err);
  }
});

export default router;
