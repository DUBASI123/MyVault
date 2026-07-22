import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
export declare class AcademicService {
    private prisma;
    private redis;
    constructor(prisma: PrismaService, redis: RedisService);
    getSubjects(branch: string, semester: number, subjectType?: string): Promise<any>;
    getSubjectContents(subjectId: string, contentType?: string): Promise<{
        description: string | null;
        title: string;
        id: string;
        createdAt: Date;
        subjectId: string;
        contentType: string;
        unitNumber: number | null;
        fileUrl: string | null;
        storagePath: string | null;
        uploadedBy: string | null;
    }[]>;
}
