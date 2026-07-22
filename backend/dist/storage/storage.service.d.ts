export declare class StorageService {
    private s3Client;
    private readonly bucketName;
    constructor();
    getPresignedDownloadUrl(key: string, fileName?: string): Promise<string>;
    getPresignedViewUrl(key: string): Promise<string>;
}
