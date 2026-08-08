import { ConfigService } from '@nestjs/config';
import { Readable } from 'stream';
export declare class StorageService {
    private config;
    private readonly s3;
    private readonly bucket;
    private readonly region;
    private readonly logger;
    constructor(config: ConfigService);
    publicUrl(key: string): string;
    getPresignedDownloadUrl(key: string, fileName?: string): Promise<string>;
    getPresignedViewUrl(key: string): Promise<string>;
    getPresignedUploadUrl(key: string, contentType: string): Promise<{
        uploadUrl: string;
        fileUrl: string;
    }>;
    uploadDirectBuffer(buffer: Buffer, key: string, contentType: string): Promise<string>;
    uploadStream(stream: Readable, key: string, contentType: string): Promise<string>;
    deleteObject(key: string): Promise<void>;
}
