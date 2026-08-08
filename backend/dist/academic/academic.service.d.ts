import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
export declare class AcademicService {
    private prisma;
    private redis;
    constructor(prisma: PrismaService, redis: RedisService);
    getSubjects(branch: string, semester: number, subjectType?: string): Promise<any>;
    getSubjectContents(subjectId: string, contentType?: string): Promise<{
        fileUrl: string | null;
        description: string | null;
        title: string;
        id: string;
        createdAt: Date;
        subjectId: string;
        contentType: string;
        unitNumber: number | null;
        storagePath: string | null;
    }[]>;
    createContent(dto: {
        subjectId: string;
        title: string;
        contentType: string;
        unitNumber?: number;
        fileUrl?: string;
        storagePath?: string;
        description?: string;
    }): Promise<{
        fileUrl: string | null;
        description: string | null;
        title: string;
        id: string;
        createdAt: Date;
        subjectId: string;
        contentType: string;
        unitNumber: number | null;
        storagePath: string | null;
    }>;
}
