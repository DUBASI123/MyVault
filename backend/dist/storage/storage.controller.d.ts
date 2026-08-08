import { Response } from 'express';
import { StorageService } from './storage.service';
export declare class StorageController {
    private readonly storageService;
    constructor(storageService: StorageService);
    getDownloadUrl(key: string, fileName?: string): Promise<{
        url: string;
    }>;
    getViewUrl(key: string): Promise<{
        url: string;
    }>;
    redirect(key: string, res: Response): Promise<void>;
    getPresignedUploadUrl(fileName: string, contentType: string, folder?: string): Promise<{
        uploadUrl: string;
        fileUrl: string;
    }>;
    uploadFile(file: {
        originalname: string;
        mimetype: string;
        buffer: Buffer;
    }, folder?: string): Promise<{
        fileUrl: string;
        key: string;
    }>;
    deleteObject(key: string): Promise<{
        deleted: boolean;
        key: string;
    }>;
}
