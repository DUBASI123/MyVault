import { Controller, Get, Post, Param, Query, Res, UseInterceptors, UploadedFile } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { StorageService } from './storage.service';

@ApiTags('S3 Storage')
@Controller('api/s3')
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Get('download/*')
  @ApiOperation({ summary: 'Get pre-signed S3 download URL' })
  async getDownloadUrl(@Param('0') path: string, @Query('fileName') fileName?: string) {
    const url = await this.storageService.getPresignedDownloadUrl(path, fileName);
    return { url };
  }

  @Get('view/*')
  @ApiOperation({ summary: 'Get pre-signed S3 view URL' })
  async getViewUrl(@Param('0') path: string) {
    const url = await this.storageService.getPresignedViewUrl(path);
    return { url };
  }

  @Get('redirect/*')
  @ApiOperation({ summary: 'Direct redirect to pre-signed S3 URL' })
  async redirectUrl(@Param('0') path: string, @Res() res: Response) {
    const url = await this.storageService.getPresignedViewUrl(path);
    return res.redirect(url);
  }

  @Get('presigned-upload')
  @ApiOperation({ summary: 'Get pre-signed S3 upload URL for CMS Website uploads' })
  async getPresignedUploadUrl(
    @Query('fileName') fileName: string,
    @Query('contentType') contentType: string,
  ) {
    const key = `cms-uploads/${Date.now()}_${fileName || 'document.pdf'}`;
    const result = await this.storageService.getPresignedUploadUrl(key, contentType || 'application/pdf');
    return result;
  }

  @Post('upload')
  @ApiOperation({ summary: 'Direct file upload to AWS S3 bucket' })
  @UseInterceptors(FileInterceptor('file'))
  async uploadFile(@UploadedFile() file: { originalname: string; mimetype: string; buffer: Buffer }) {
    if (!file) throw new Error('File required');
    const key = `cms-uploads/${Date.now()}_${file.originalname}`;
    const fileUrl = await this.storageService.uploadDirectBuffer(file.buffer, key, file.mimetype);
    return { fileUrl };
  }
}
