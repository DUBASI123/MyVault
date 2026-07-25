import { ContentService } from './content.service';
export declare class ContentController {
    private readonly contentService;
    constructor(contentService: ContentService);
    getTicker(): Promise<any>;
    getNotifications(): Promise<{
        id: string;
        title: string;
        message: string;
        type: string;
        createdAt: Date;
    }[]>;
    getResults(branch?: string, semester?: number): Promise<{
        id: string;
        subject: string;
        code: string;
        internal: number;
        external: number;
        total: number;
        max: number;
        grade: string;
        status: string;
        branch: string;
        semester: number;
        createdAt: Date;
    }[]>;
    getInternships(type?: string): Promise<{
        id: string;
        company: string;
        role: string;
        type: string;
        domain: string;
        stipend: string;
        duration: string;
        deadline: string;
        applyLink: string;
        status: string;
        createdAt: Date;
    }[]>;
}
