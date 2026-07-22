import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

@ApiTags('System')
@Controller()
export class AppController {
  @Get('download-apk')
  @ApiOperation({ summary: 'Download latest MyVault release APK' })
  downloadApk(@Res() res: Response) {
    // Redirect directly to AWS S3 bucket release APK mirror
    return res.redirect(
      'https://myvault-files.s3.eu-north-1.amazonaws.com/downloads/MyVault-release.apk',
    );
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
