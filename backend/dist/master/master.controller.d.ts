import { MasterService } from './master.service';
export declare class MasterController {
    private readonly masterService;
    constructor(masterService: MasterService);
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
