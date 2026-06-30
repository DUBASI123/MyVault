import { Router } from 'express';
import { getPresignedViewUrl, getPresignedDownloadUrl } from '../lib/s3.js';

const router = Router();

/**
 * GET /api/s3/view/*path
 * Returns a fresh pre-signed S3 URL for viewing a file.
 * Express v5 requires named wildcard params (*path instead of *)
 */
router.get('/view/*path', async (req, res, next) => {
  try {
    const key = req.params.path;
    if (!key) return res.status(400).json({ error: 'File key is required' });

    const url = await getPresignedViewUrl(key);
    res.json({ url });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/s3/download/*path
 * Returns a fresh pre-signed S3 URL that forces a file download.
 */
router.get('/download/*path', async (req, res, next) => {
  try {
    const key = req.params.path;
    const fileName = req.query.fileName || key.split('/').pop();
    if (!key) return res.status(400).json({ error: 'File key is required' });

    const url = await getPresignedDownloadUrl(key, fileName);
    res.json({ url });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/s3/redirect/*path
 * Directly redirects to the pre-signed S3 URL.
 * The Flutter app stores this as file_url and opens it directly.
 */
router.get('/redirect/*path', async (req, res, next) => {
  try {
    const key = req.params.path;
    if (!key) return res.status(400).json({ error: 'File key is required' });

    const url = await getPresignedViewUrl(key);
    res.redirect(url);
  } catch (err) {
    next(err);
  }
});

export default router;
