import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { createServer } from 'http';

import path from 'path';
import fs from 'fs';

import authRoutes from './routes/auth.routes.js';
import masterRoutes from './routes/master.routes.js';
import academicRoutes from './routes/academic.routes.js';
import contentRoutes from './routes/content.routes.js';
import s3Routes from './routes/s3.routes.js';
import { getLiveStatus } from './lib/live_status.js';
import { initSocket } from './services/socket_service.js';
import { getPresignedDownloadUrl } from './lib/s3.js';

import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));

app.get('/api/health', (_, res) => {
  res.json({ status: 'ok', service: 'my-vault-api' });
});

app.get('/', (_, res) => {
  res.json({
    status: 'ok',
    message: 'MyVault REST API is running successfully.',
    downloadUrl: 'https://myvault-jbd7.onrender.com/download-apk'
  });
});

app.get('/download-apk', async (_, res) => {
  try {
    const key = 'downloads/MyVault-release.apk';
    const fileName = 'MyVault-release.apk';
    const downloadUrl = await getPresignedDownloadUrl(key, fileName);
    return res.redirect(downloadUrl);
  } catch (err) {
    console.error('Error generating S3 pre-signed download URL:', err);
    
    // Fallback to local file download if available
    const apkPath = path.join(__dirname, '../public/MyVault-release.apk');
    if (fs.existsSync(apkPath)) {
      return res.download(apkPath, 'MyVault-release.apk');
    }

    res.setHeader('Content-Type', 'text/html');
    return res.status(200).send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>MyVault APK Download</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #121212; color: #ffffff; text-align: center; padding: 50px; }
          .card { background-color: #1e1e1e; padding: 40px; border-radius: 16px; display: inline-block; max-width: 500px; box-shadow: 0 8px 24px rgba(0,0,0,0.5); border: 1.5px solid #22c55e; }
          h1 { color: #22c55e; margin-bottom: 20px; }
          p { font-size: 15px; color: #b3b3b3; line-height: 1.6; }
          .path { background-color: #2a2a2a; padding: 8px 12px; border-radius: 6px; font-family: monospace; color: #22c55e; margin: 15px 0; word-break: break-all; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>MyVault APK</h1>
          <p>To keep the repository clean and light, the 71MB release APK is stored directly on your computer's local workspace at:</p>
          <div class="path">MyVault/backend/public/MyVault-release.apk</div>
          <p>You can copy this file directly to your phone via USB, or upload it to your personal Google Drive to install it instantly!</p>
        </div>
      </body>
      </html>
    `);
  }
});

app.get('/api/health/live', async (_req, res, next) => {
  try {
    res.json(await getLiveStatus());
  } catch (err) {
    next(err);
  }
});

app.use('/api/auth', authRoutes);
app.use('/api/master', masterRoutes);
app.use('/api/academic', academicRoutes);
app.use('/api/content', contentRoutes);
app.use('/api/s3', s3Routes);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

const server = createServer(app);
initSocket(server);

server.listen(PORT, () => {
  console.log(`My Vault API running on http://localhost:${PORT}`);
});
