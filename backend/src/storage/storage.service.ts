import { Injectable, BadRequestException } from '@nestjs/common';

@Injectable()
export class StorageService {
  private readonly bucketName = 'myvault-files';

  constructor() {}

  async getPresignedDownloadUrl(key: string, fileName?: string): Promise<string> {
    if (!key) throw new BadRequestException('Key required');
    return `https://myvault-files.s3.eu-north-1.amazonaws.com/${key}`;
  }

  async getPresignedViewUrl(key: string): Promise<string> {
    if (!key) throw new BadRequestException('Key required');
    return `https://mock.s3.amazonaws.com/${key}`;
  }

  async getPresignedUploadUrl(key: string, contentType: string): Promise<{ uploadUrl: string; fileUrl: string }> {
    if (!key) throw new BadRequestException('Key required');
    const fileUrl = `https://${this.bucketName}.s3.amazonaws.com/${key}`;
    return { uploadUrl: `https://mock.s3.amazonaws.com/${key}?upload=1`, fileUrl };
  }

  async uploadDirectBuffer(buffer: Buffer, key: string, contentType: string): Promise<string> {
    return `https://${this.bucketName}.s3.amazonaws.com/${key}`;
  }
}
