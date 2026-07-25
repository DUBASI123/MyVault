import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
export declare class AcademicService {
    private prisma;
    private redis;
    constructor(prisma: PrismaService, redis: RedisService);
    getSubjects(branch: string, semester: number, subjectType?: string): Promise<any>;
    getSubjectContents(subjectId: string, contentType?: string): Promise<{
        id: string;
        subjectId: any;
        title: string;
        contentType: string;
        description: string;
        unitNumber: number;
        fileUrl: string;
        createdAt: Date;
    }[]>;
}
