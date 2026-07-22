import { Controller, Get, Param, Query, Res } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
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
}
