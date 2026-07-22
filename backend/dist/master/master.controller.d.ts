import { MasterService } from './master.service';
export declare class MasterController {
    private readonly masterService;
    constructor(masterService: MasterService);
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
