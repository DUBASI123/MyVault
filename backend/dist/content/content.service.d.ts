import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
export declare class ContentService {
    private prisma;
    private redis;
    constructor(prisma: PrismaService, redis: RedisService);
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
