import {
  Controller, Get, Post, Delete,
  Param, Query, Body, Res,
  UseInterceptors, UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBody, ApiConsumes } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { StorageService } from './storage.service';

@ApiTags('S3 Storage')
@Controller('api/s3')
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  // ── PRESIGNED DOWNLOAD URL ───────────────────────────────────────────────
  @Get('download/*')
  @ApiOperation({ summary: 'Get presigned S3 download URL (15 min expiry)' })
  @ApiQuery({ name: 'fileName', required: false })
  async getDownloadUrl(
    @Param('0') key: string,
    @Query('fileName') fileName?: string,
  ) {
    if (!key) throw new BadRequestException('S3 key required');
    const url = await this.storageService.getPresignedDownloadUrl(key, fileName);
    return { url };
  }

  // ── PRESIGNED VIEW URL ───────────────────────────────────────────────────
  @Get('view/*')
  @ApiOperation({ summary: 'Get presigned S3 inline view URL (1 hr expiry)' })
  async getViewUrl(@Param('0') key: string) {
    if (!key) throw new BadRequestException('S3 key required');
    const url = await this.storageService.getPresignedViewUrl(key);
    return { url };
  }

  // ── REDIRECT TO PRESIGNED URL ────────────────────────────────────────────
  @Get('redirect/*')
  @ApiOperation({ summary: 'Redirect browser directly to presigned S3 view URL' })
  async redirect(@Param('0') key: string, @Res() res: Response) {
    const url = await this.storageService.getPresignedViewUrl(key);
    return res.redirect(302, url);
  }

  // ── GET PRESIGNED UPLOAD URL (website / CMS uses this) ──────────────────
  @Get('presign-upload')
  @ApiOperation({ summary: 'Get presigned S3 PUT URL — browser uploads directly to S3' })
  @ApiQuery({ name: 'fileName', required: true, example: 'DLD_notes.pdf' })
  @ApiQuery({ name: 'contentType', required: false, example: 'application/pdf' })
  @ApiQuery({ name: 'folder', required: false, example: 'study-materials', description: 'S3 folder prefix' })
  async getPresignedUploadUrl(
    @Query('fileName') fileName: string,
    @Query('contentType') contentType: string,
    @Query('folder') folder: string = 'study-materials',
  ) {
    if (!fileName) throw new BadRequestException('fileName is required');
    const safeName = fileName.replace(/\s+/g, '-');
    const key = `${folder}/${Date.now()}_${safeName}`;
    return this.storageService.getPresignedUploadUrl(key, contentType || 'application/octet-stream');
  }

  // ── DIRECT UPLOAD (backend receives file, uploads to S3) ─────────────────
  @Post('upload')
  @ApiOperation({ summary: 'Upload file via backend → S3 (use presign-upload for large files)' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({ description: 'File upload', schema: { type: 'object', properties: { file: { type: 'string', format: 'binary' }, folder: { type: 'string' } } } })
  @UseInterceptors(FileInterceptor('file'))
  async uploadFile(
    @UploadedFile() file: { originalname: string; mimetype: string; buffer: Buffer },
    @Query('folder') folder: string = 'study-materials',
  ) {
    if (!file) throw new BadRequestException('file is required');
    const key = `${folder}/${Date.now()}_${file.originalname.replace(/\s+/g, '-')}`;
    const fileUrl = await this.storageService.uploadDirectBuffer(file.buffer, key, file.mimetype);
    return { fileUrl, key };
  }

  // ── DELETE OBJECT ────────────────────────────────────────────────────────
  @Delete('object/*')
  @ApiOperation({ summary: 'Delete an object from S3 by key' })
  async deleteObject(@Param('0') key: string) {
    if (!key) throw new BadRequestException('S3 key required');
    await this.storageService.deleteObject(key);
    return { deleted: true, key };
  }
}
