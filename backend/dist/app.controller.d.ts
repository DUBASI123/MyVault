import { Response } from 'express';
export declare class AppController {
    downloadApk(res: Response): void;
    getRoot(): {
        status: string;
        app: string;
        version: string;
        docs: string;
        downloadApk: string;
    };
}
