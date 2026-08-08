import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Upload } from '@aws-sdk/lib-storage';
import { Readable } from 'stream';

@Injectable()
export class StorageService {
  private readonly s3: S3Client;
  private readonly bucket: string;
  private readonly region: string;
  private readonly logger = new Logger(StorageService.name);

  constructor(private config: ConfigService) {
    this.region = this.config.get<string>('AWS_REGION') || 'ap-south-1';
    this.bucket = this.config.get<string>('AWS_BUCKET_NAME') || 'myvault-study-materials';

    this.s3 = new S3Client({
      region: this.region,
      credentials: {
        accessKeyId: this.config.get<string>('AWS_ACCESS_KEY_ID') || '',
        secretAccessKey: this.config.get<string>('AWS_SECRET_ACCESS_KEY') || '',
      },
    });

    this.logger.log(`✅ S3 client initialised — bucket: ${this.bucket} | region: ${this.region}`);
  }

  // ── PUBLIC URL (for publicly readable buckets) ──────────────────────────
  publicUrl(key: string): string {
    return `https://${this.bucket}.s3.${this.region}.amazonaws.com/${key}`;
  }

  // ── PRESIGNED DOWNLOAD URL (15 min expiry) ───────────────────────────────
  async getPresignedDownloadUrl(key: string, fileName?: string): Promise<string> {
    if (!key) throw new BadRequestException('S3 key is required');

    const command = new GetObjectCommand({
      Bucket: this.bucket,
      Key: key,
      ...(fileName && {
        ResponseContentDisposition: `attachment; filename="${encodeURIComponent(fileName)}"`,
      }),
    });

    return getSignedUrl(this.s3, command, { expiresIn: 900 }); // 15 min
  }

  // ── PRESIGNED VIEW URL (1 hr expiry, inline display) ────────────────────
  async getPresignedViewUrl(key: string): Promise<string> {
    if (!key) throw new BadRequestException('S3 key is required');

    const command = new GetObjectCommand({
      Bucket: this.bucket,
      Key: key,
      ResponseContentDisposition: 'inline',
    });

    return getSignedUrl(this.s3, command, { expiresIn: 3600 }); // 1 hr
  }

  // ── PRESIGNED UPLOAD URL (5 min expiry, browser → S3 direct PUT) ────────
  async getPresignedUploadUrl(
    key: string,
    contentType: string,
  ): Promise<{ uploadUrl: string; fileUrl: string }> {
    if (!key) throw new BadRequestException('S3 key is required');

    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: key,
      ContentType: contentType,
    });

    const uploadUrl = await getSignedUrl(this.s3, command, { expiresIn: 300 }); // 5 min
    const fileUrl = this.publicUrl(key);

    this.logger.log(`🔗 Presigned upload URL generated for key: ${key}`);
    return { uploadUrl, fileUrl };
  }

  // ── DIRECT BUFFER UPLOAD (backend → S3, for small files) ────────────────
  async uploadDirectBuffer(
    buffer: Buffer,
    key: string,
    contentType: string,
  ): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: key,
      Body: buffer,
      ContentType: contentType,
    });

    await this.s3.send(command);
    this.logger.log(`📤 Direct upload complete: ${key}`);
    return this.publicUrl(key);
  }

  // ── MULTIPART UPLOAD (for large files > 5MB) ───────────────────────────
  async uploadStream(
    stream: Readable,
    key: string,
    contentType: string,
  ): Promise<string> {
    const upload = new Upload({
      client: this.s3,
      params: {
        Bucket: this.bucket,
        Key: key,
        Body: stream,
        ContentType: contentType,
      },
      queueSize: 4,
      partSize: 5 * 1024 * 1024, // 5 MB parts
    });

    upload.on('httpUploadProgress', (progress) => {
      this.logger.log(`⬆️  ${key}: ${progress.loaded}/${progress.total} bytes`);
    });

    await upload.done();
    this.logger.log(`✅ Multipart upload complete: ${key}`);
    return this.publicUrl(key);
  }

  // ── DELETE OBJECT ────────────────────────────────────────────────────────
  async deleteObject(key: string): Promise<void> {
    await this.s3.send(new DeleteObjectCommand({ Bucket: this.bucket, Key: key }));
    this.logger.log(`🗑️  Deleted: ${key}`);
  }
}
