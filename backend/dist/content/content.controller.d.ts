import { ContentService } from './content.service';
export declare class ContentController {
    private readonly contentService;
    constructor(contentService: ContentService);
    getTicker(): Promise<any>;
    getNotifications(): Promise<{
        type: string;
        title: string;
        branch: string | null;
        semester: number | null;
        id: string;
        createdAt: Date;
        message: string;
        imageUrl: string | null;
    }[]>;
    getResults(branch?: string, semester?: number): Promise<{
        subject: string;
        branch: string;
        semester: number;
        id: string;
        createdAt: Date;
        code: string | null;
        internal: number;
        external: number;
        total: number;
        max: number;
        grade: string | null;
        status: string;
    }[]>;
    getInternships(type?: string): Promise<{
        type: string;
        id: string;
        role: string;
        createdAt: Date;
        status: string;
        company: string;
        domain: string | null;
        stipend: string | null;
        duration: string | null;
        deadline: string | null;
        applyLink: string | null;
    }[]>;
}
