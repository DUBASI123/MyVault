import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { StorageService } from './storage/storage.service';

@ApiTags('System')
@Controller()
export class AppController {
  constructor(private readonly storageService: StorageService) {}

  @Get('download-apk')
  @ApiOperation({ summary: 'Download latest MyVault release APK' })
  async downloadApk(@Res() res: Response) {
    try {
      // Generate AWS S3 signed URL (valid for 1 hr) to bypass AccessDenied restrictions
      const signedUrl = await this.storageService.getPresignedDownloadUrl(
        'downloads/MyVault-release.apk',
        'MyVault-release.apk',
      );
      return res.redirect(signedUrl);
    } catch (err) {
      // Fallback mirror URL
      return res.redirect(
        'https://myvault-files.s3.eu-north-1.amazonaws.com/downloads/MyVault-release.apk',
      );
    }
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
