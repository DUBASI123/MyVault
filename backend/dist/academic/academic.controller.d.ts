import { AcademicService } from './academic.service';
export declare class AcademicController {
    private readonly academicService;
    constructor(academicService: AcademicService);
    getSubjects(branch: string, semester: number, subjectType?: string): Promise<any>;
    getContents(subjectId: string, contentType?: string): Promise<{
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
