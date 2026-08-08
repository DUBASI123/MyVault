import { AcademicService } from './academic.service';
export declare class CreateContentDto {
    subjectId: string;
    title: string;
    contentType: string;
    unitNumber?: number;
    fileUrl?: string;
    storagePath?: string;
    description?: string;
}
export declare class AcademicController {
    private readonly academicService;
    constructor(academicService: AcademicService);
    getSubjects(branch: string, semester: string, subjectType?: string): Promise<any>;
    getSubjectContents(subjectId: string, contentType?: string): Promise<{
        fileUrl: string | null;
        description: string | null;
        title: string;
        id: string;
        createdAt: Date;
        subjectId: string;
        contentType: string;
        unitNumber: number | null;
        storagePath: string | null;
    }[]>;
    createContent(dto: CreateContentDto): Promise<{
        fileUrl: string | null;
        description: string | null;
        title: string;
        id: string;
        createdAt: Date;
        subjectId: string;
        contentType: string;
        unitNumber: number | null;
        storagePath: string | null;
    }>;
}
