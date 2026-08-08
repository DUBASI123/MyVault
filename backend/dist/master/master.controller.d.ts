import { MasterService } from './master.service';
export declare class MasterController {
    private readonly masterService;
    constructor(masterService: MasterService);
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
