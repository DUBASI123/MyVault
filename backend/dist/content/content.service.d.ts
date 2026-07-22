import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
export declare class ContentService {
    private prisma;
    private redis;
    constructor(prisma: PrismaService, redis: RedisService);
    getTicker(): Promise<any>;
    getNotifications(): Promise<{
        type: string;
        title: string;
        id: string;
        createdAt: Date;
        link: string | null;
        body: string;
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
        maxMarks: number;
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
        logo: string | null;
    }[]>;
}
