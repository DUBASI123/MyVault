import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { StorageService } from './storage/storage.service';
import * as path from 'path';
import * as fs from 'fs';

@ApiTags('System')
@Controller()
export class AppController {
  constructor(private readonly storageService: StorageService) {}

  @Get('download-apk')
  @ApiOperation({ summary: 'Download latest MyVault release APK' })
  async downloadApk(@Res() res: Response) {
    const apkPath = path.join(__dirname, '..', 'public', 'MyVault-release.apk');
    if (fs.existsSync(apkPath)) {
      return res.download(apkPath, 'MyVault.apk');
    }
    return res.status(404).send('APK file not found on server');
  }

  @Get()
  @ApiOperation({ summary: 'Backend root status check' })
  getRoot() {
    return {
      status: 'online',
      app: 'MyVault Enterprise NestJS Backend',
      version: '1.1.0',
      docs: '/api/docs',
      downloadApk: '/download-apk',
    };
  }
}
