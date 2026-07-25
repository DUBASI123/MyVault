import { MasterService } from './master.service';
export declare class MasterController {
    private readonly masterService;
    constructor(masterService: MasterService);
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
