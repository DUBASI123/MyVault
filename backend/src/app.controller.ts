import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import * as path from 'path';
import * as fs from 'fs';

function getPublicFolderPath(): string {
  const candidates = [
    path.join(process.cwd(), 'public'),
    path.join(process.cwd(), 'backend', 'public'),
    path.join(__dirname, '..', 'public'),
    path.join(__dirname, '..', '..', 'public'),
  ];
  for (const c of candidates) {
    if (fs.existsSync(path.join(c, 'index.html'))) return c;
  }
  return path.join(process.cwd(), 'public');
}

@ApiTags('System')
@Controller()
export class AppController {
  @Get('download-apk')
  @ApiOperation({ summary: 'Download latest MyVault release APK' })
  async downloadApk(@Res() res: Response) {
    const publicDir = getPublicFolderPath();
    const apkPath = path.join(publicDir, 'MyVault-release.apk');
    if (fs.existsSync(apkPath)) {
      return res.download(apkPath, 'MyVault.apk');
    }
    return res.status(404).json({ error: 'APK file not found on server' });
  }

  @Get('health')
  @ApiOperation({ summary: 'Backend status check' })
  getHealth() {
    return {
      status: 'online',
      app: 'MyVault Enterprise NestJS Backend',
      version: '1.1.0',
      docs: '/api/docs',
    };
  }

  @Get()
  @ApiOperation({ summary: 'Serve MyVault Website index.html or Root Status' })
  getRoot(@Res() res: Response) {
    const publicDir = getPublicFolderPath();
    const indexPath = path.join(publicDir, 'index.html');
    if (fs.existsSync(indexPath)) {
      return res.sendFile(indexPath);
    }
    return res.json({
      status: 'online',
      app: 'MyVault Enterprise NestJS Backend',
      version: '1.1.0',
      docs: '/api/docs',
      website: 'Place index.html in /public folder',
    });
  }
}
