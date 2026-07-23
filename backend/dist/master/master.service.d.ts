import { PrismaService } from '../prisma/prisma.service';
export declare class MasterService {
    private prisma;
    constructor(prisma: PrismaService);
    getUniversities(): Promise<{
        name: string;
        id: string;
        state: string | null;
        createdAt: Date;
        code: string;
    }[]>;
    getColleges(universityId?: string): Promise<{
        name: string;
        type: string | null;
        id: string;
        universityId: string;
        state: string | null;
        createdAt: Date;
        code: string;
        logoUrl: string | null;
        district: string | null;
    }[]>;
}
