import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { createServer } from 'http';

import path from 'path';

import authRoutes from './routes/auth.routes.js';
import masterRoutes from './routes/master.routes.js';
import academicRoutes from './routes/academic.routes.js';
import contentRoutes from './routes/content.routes.js';
import { getLiveStatus } from './lib/live_status.js';
import { initSocket } from './services/socket_service.js';

dotenv.config();

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

app.get('/download-apk', (_, res) => {
  res.redirect('https://oawomrlsitttrbulxgyk.supabase.co/storage/v1/object/public/academic-files/MyVault-release.apk');
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

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

const server = createServer(app);
initSocket(server);

server.listen(PORT, () => {
  console.log(`My Vault API running on http://localhost:${PORT}`);
});
