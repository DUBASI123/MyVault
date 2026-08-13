import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { StorageService } from './storage/storage.service';
import * as path from 'path';
import * as fs from 'fs';

function getApkFilePath(): string | null {
  const candidates = [
    path.join(process.cwd(), 'public', 'MyVault-release.apk'),
    path.join(process.cwd(), 'backend', 'public', 'MyVault-release.apk'),
    path.join(__dirname, '..', 'public', 'MyVault-release.apk'),
    path.join(__dirname, '..', '..', 'public', 'MyVault-release.apk'),
  ];
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  return null;
}

@ApiTags('System')
@Controller()
export class AppController {
  constructor(private readonly storageService: StorageService) {}

  @Get('download-apk')
  @ApiOperation({ summary: 'Download latest MyVault release APK' })
  async downloadApk(@Res() res: Response) {
    const apkPath = getApkFilePath();

    // 1. If APK file exists on server disk, stream directly
    if (apkPath) {
      return res.download(apkPath, 'MyVault.apk');
    }

    // 2. Fallback to S3 only if S3 is configured
    try {
      const s3Url = await this.storageService.getPresignedDownloadUrl(
        'downloads/MyVault-release.apk',
        'MyVault.apk',
      );
      return res.redirect(302, s3Url);
    } catch (_) {
      const publicS3Url = this.storageService.publicUrl('downloads/MyVault-release.apk');
      return res.redirect(302, publicS3Url);
    }
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
  @ApiOperation({ summary: 'Backend Root Status' })
  getRoot() {
    return {
      status: 'online',
      app: 'MyVault Enterprise NestJS Backend',
      version: '1.1.0',
      docs: '/api/docs',
      apkDownload: '/download-apk',
    };
  }
}
