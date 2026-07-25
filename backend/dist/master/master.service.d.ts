import { PrismaService } from '../prisma/prisma.service';
export declare class MasterService {
    private prisma;
    constructor(prisma: PrismaService);
    getUniversities(): Promise<{
        id: string;
        name: string;
        code: string;
        state: string;
        createdAt: Date;
    }[]>;
    getColleges(universityId?: string): Promise<{
        id: string;
        universityId: string;
        name: string;
        code: string;
        district: string;
        type: string;
    }[]>;
}
