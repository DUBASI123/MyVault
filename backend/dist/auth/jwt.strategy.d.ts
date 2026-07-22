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
        firstName: string;
        lastName: string;
        fullNameAadhar: string;
        mobile: string;
        email: string;
        hallTicket: string;
        branch: string;
        course: string;
        semester: number;
        profilePicUrl: string | null;
        idCardUrl: string | null;
        id: string;
        passwordHash: string | null;
        universityId: string | null;
        collegeId: string | null;
        yearOfStudy: number;
        passingYear: number | null;
        gender: string | null;
        state: string | null;
        role: string;
        isMobileVerified: boolean;
        isEmailVerified: boolean;
        verificationStatus: string;
        isVerified: boolean;
        rejectionReason: string | null;
        rewardPoints: number;
        createdAt: Date;
    }>;
}
export {};
