import { OnModuleInit, OnModuleDestroy } from '@nestjs/common';
export declare class PrismaService implements OnModuleInit, OnModuleDestroy {
    onModuleInit(): Promise<void>;
    onModuleDestroy(): Promise<void>;
    university: {
        findMany: (args?: any) => Promise<{
            id: string;
            name: string;
            code: string;
            state: string;
            createdAt: Date;
        }[]>;
    };
    college: {
        findMany: (args?: any) => Promise<{
            id: string;
            universityId: string;
            name: string;
            code: string;
            district: string;
            type: string;
        }[]>;
    };
    student: {
        findFirst: (args?: any) => Promise<{
            id: string;
            firstName: string;
            lastName: string;
            fullNameAadhar: string;
            mobile: string;
            email: string;
            passwordHash: string;
            hallTicket: string;
            universityId: string;
            collegeId: string;
            course: string;
            branch: string;
            semester: number;
            role: string;
            university: {
                id: string;
                name: string;
                code: string;
            };
            college: {
                id: string;
                name: string;
                code: string;
            };
        }>;
        findUnique: (args?: any) => Promise<{
            id: any;
            firstName: string;
            lastName: string;
            fullNameAadhar: string;
            mobile: string;
            email: string;
            passwordHash: string;
            hallTicket: string;
            universityId: string;
            collegeId: string;
            course: string;
            branch: string;
            semester: number;
            role: string;
            university: {
                id: string;
                name: string;
                code: string;
            };
            college: {
                id: string;
                name: string;
                code: string;
            };
        }>;
        create: (args?: any) => Promise<any>;
        update: (args?: any) => Promise<any>;
    };
    subject: {
        findMany: (args?: any) => Promise<{
            id: string;
            name: string;
            code: string;
            branch: string;
            semester: number;
            subjectType: string;
        }[]>;
    };
    academicContent: {
        findMany: (args?: any) => Promise<{
            id: string;
            subjectId: any;
            title: string;
            contentType: string;
            description: string;
            unitNumber: number;
            fileUrl: string;
            createdAt: Date;
        }[]>;
        findUnique: (args?: any) => Promise<{
            id: any;
            title: string;
            fileUrl: string;
            createdAt: Date;
        }>;
        create: (args?: any) => Promise<any>;
        delete: (args?: any) => Promise<{
            id: any;
        }>;
    };
    notification: {
        findMany: (args?: any) => Promise<{
            id: string;
            title: string;
            message: string;
            type: string;
            createdAt: Date;
        }[]>;
    };
    examResult: {
        findMany: (args?: any) => Promise<{
            id: string;
            subject: string;
            code: string;
            internal: number;
            external: number;
            total: number;
            max: number;
            grade: string;
            status: string;
            branch: string;
            semester: number;
            createdAt: Date;
        }[]>;
    };
    internship: {
        findMany: (args?: any) => Promise<{
            id: string;
            company: string;
            role: string;
            type: string;
            domain: string;
            stipend: string;
            duration: string;
            deadline: string;
            applyLink: string;
            status: string;
            createdAt: Date;
        }[]>;
    };
}
