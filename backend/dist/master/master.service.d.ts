import { PrismaService } from '../prisma/prisma.service';
export declare class MasterService {
    private prisma;
    constructor(prisma: PrismaService);
    getUniversities(): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        code: string;
        state: string;
    }[]>;
    getColleges(universityId?: string): Promise<{
        name: string;
        type: string;
        id: string;
        universityId: string;
        createdAt: Date;
        code: string;
        district: string | null;
    }[]>;
}
