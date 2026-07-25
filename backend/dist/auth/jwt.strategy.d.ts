import { Strategy } from 'passport-jwt';
import { PrismaService } from '../prisma/prisma.service';
declare const JwtStrategy_base: new (...args: any[]) => Strategy;
export declare class JwtStrategy extends JwtStrategy_base {
    private prisma;
    constructor(prisma: PrismaService);
    validate(payload: {
        sub: string;
        role: string;
    }): Promise<{
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
}
export {};
