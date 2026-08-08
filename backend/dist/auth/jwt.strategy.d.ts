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
        mobile: string;
        firstName: string;
        lastName: string;
        fullNameAadhar: string | null;
        email: string | null;
        hallTicket: string;
        branch: string;
        course: string;
        semester: number;
        profilePicUrl: string | null;
        idCardUrl: string | null;
        id: string;
        passwordHash: string;
        universityId: string | null;
        collegeId: string | null;
        role: string;
        fcmToken: string | null;
        isMobileVerified: boolean;
        isEmailVerified: boolean;
        verificationStatus: string;
        isVerified: boolean;
        createdAt: Date;
        updatedAt: Date;
    }>;
}
export {};
