import { Response } from 'express';
import { StorageService } from './storage/storage.service';
export declare class AppController {
    private readonly storageService;
    constructor(storageService: StorageService);
    downloadApk(res: Response): Promise<void | Response<any, Record<string, any>>>;
    getRoot(): {
        status: string;
        app: string;
        version: string;
        docs: string;
        downloadApk: string;
    };
}
