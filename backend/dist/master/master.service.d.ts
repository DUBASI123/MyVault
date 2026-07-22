import { PrismaService } from '../prisma/prisma.service';
export declare class MasterService {
    private prisma;
    constructor(prisma: PrismaService);
    getUniversities(): Promise<{
        id: string;
        state: string | null;
        createdAt: Date;
        name: string;
        code: string;
    }[]>;
    getColleges(universityId?: string): Promise<{
        type: string | null;
        id: string;
        universityId: string;
        state: string | null;
        createdAt: Date;
        name: string;
        code: string;
        logoUrl: string | null;
        district: string | null;
    }[]>;
}
