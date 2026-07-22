import { AcademicService } from './academic.service';
export declare class AcademicController {
    private readonly academicService;
    constructor(academicService: AcademicService);
    getSubjects(branch: string, semester: number, subjectType?: string): Promise<any>;
    getContents(subjectId: string, contentType?: string): Promise<{
        description: string | null;
        title: string;
        id: string;
        createdAt: Date;
        subjectId: string;
        contentType: string;
        unitNumber: number | null;
        fileUrl: string | null;
        storagePath: string | null;
        uploadedBy: string | null;
    }[]>;
}
