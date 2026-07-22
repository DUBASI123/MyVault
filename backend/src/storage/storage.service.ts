import { Injectable, BadRequestException } from '@nestjs/common';
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

@Injectable()
export class StorageService {
  private s3Client: S3Client;
  private readonly bucketName = process.env.AWS_S3_BUCKET || 'myvault-files';

  constructor() {
    this.s3Client = new S3Client({
      region: process.env.AWS_REGION || 'eu-north-1',
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
      },
    });
  }

  async getPresignedDownloadUrl(key: string, fileName?: string): Promise<string> {
    if (!key) throw new BadRequestException('Key required');
    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
      ResponseContentDisposition: `attachment; filename="${fileName || key.split('/').pop()}"`,
    });
    return getSignedUrl(this.s3Client, command, { expiresIn: 3600 });
  }

  async getPresignedViewUrl(key: string): Promise<string> {
    if (!key) throw new BadRequestException('Key required');
    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
      ResponseContentDisposition: 'inline',
    });
    return getSignedUrl(this.s3Client, command, { expiresIn: 3600 });
  }
}
