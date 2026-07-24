import { Response } from 'express';
import { StorageService } from './storage.service';
export declare class StorageController {
    private readonly storageService;
    constructor(storageService: StorageService);
    getDownloadUrl(path: string, fileName?: string): Promise<{
        url: string;
    }>;
    getViewUrl(path: string): Promise<{
        url: string;
    }>;
    redirectUrl(path: string, res: Response): Promise<void>;
    getPresignedUploadUrl(fileName: string, contentType: string): Promise<{
        uploadUrl: string;
        fileUrl: string;
    }>;
    uploadFile(file: {
        originalname: string;
        mimetype: string;
        buffer: Buffer;
    }): Promise<{
        fileUrl: string;
    }>;
}
