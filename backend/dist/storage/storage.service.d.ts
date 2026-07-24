export declare class StorageService {
    private s3Client;
    private readonly bucketName;
    constructor();
    getPresignedDownloadUrl(key: string, fileName?: string): Promise<string>;
    getPresignedViewUrl(key: string): Promise<string>;
    getPresignedUploadUrl(key: string, contentType: string): Promise<{
        uploadUrl: string;
        fileUrl: string;
    }>;
    uploadDirectBuffer(buffer: Buffer, key: string, contentType: string): Promise<string>;
}
