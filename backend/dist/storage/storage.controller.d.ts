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
}
