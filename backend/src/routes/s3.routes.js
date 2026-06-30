import { Router } from 'express';
import { getPresignedViewUrl, getPresignedDownloadUrl } from '../lib/s3.js';

const router = Router();

const getCleanPath = (pathParam) => {
  if (Array.isArray(pathParam)) {
    return pathParam.join('/');
  }
  return pathParam || '';
};

/**
 * GET /api/s3/view/*path
 * Returns a fresh pre-signed S3 URL for viewing a file.
 */
router.get('/view/*path', async (req, res, next) => {
  try {
    const key = getCleanPath(req.params.path);
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
    const key = getCleanPath(req.params.path);
    if (!key) return res.status(400).json({ error: 'File key is required' });
    const fileName = req.query.fileName || key.split('/').pop();

    const url = await getPresignedDownloadUrl(key, fileName);
    res.json({ url });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/s3/redirect/*path
 * Directly redirects to the pre-signed S3 URL.
 */
router.get('/redirect/*path', async (req, res, next) => {
  try {
    const key = getCleanPath(req.params.path);
    if (!key) return res.status(400).json({ error: 'File key is required' });

    const url = await getPresignedViewUrl(key);
    res.redirect(url);
  } catch (err) {
    next(err);
  }
});

export default router;
