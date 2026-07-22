"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcryptjs");
const prisma_service_1 = require("../prisma/prisma.service");
let AuthService = class AuthService {
    constructor(prisma, jwtService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
    }
    async login(dto) {
        const id = dto.identifier.trim();
        const student = await this.prisma.student.findFirst({
            where: {
                OR: [
                    { email: id.toLowerCase() },
                    { hallTicket: id },
                    { mobile: id },
                ],
            },
            include: { university: true, college: true },
        });
        if (!student || !student.passwordHash) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const valid = await bcrypt.compare(dto.password, student.passwordHash);
        if (!valid) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const payload = { sub: student.id, role: student.role };
        const accessToken = this.jwtService.sign(payload);
        const refreshToken = this.jwtService.sign(payload, { expiresIn: '30d' });
        return {
            token: accessToken,
            refreshToken,
            student: this.sanitizeStudent(student),
        };
    }
    async register(dto) {
        const existing = await this.prisma.student.findFirst({
            where: {
                OR: [
                    { email: dto.email.toLowerCase() },
                    { mobile: dto.mobile },
                    { hallTicket: dto.hallTicket },
                ],
            },
        });
        if (existing) {
            throw new common_1.ConflictException('Email, mobile, or hall ticket already registered');
        }
        const passwordHash = await bcrypt.hash(dto.password, 10);
        const student = await this.prisma.student.create({
            data: {
                firstName: dto.firstName,
                lastName: dto.lastName,
                fullNameAadhar: dto.fullNameAadhar,
                mobile: dto.mobile,
                email: dto.email.toLowerCase(),
                passwordHash,
                hallTicket: dto.hallTicket,
                course: dto.course || 'B.Tech',
                branch: dto.branch || 'CSE',
                semester: dto.semester || 1,
                profilePicUrl: dto.profilePicUrl || null,
                idCardUrl: dto.idCardUrl || null,
                isMobileVerified: true,
                isEmailVerified: true,
                verificationStatus: 'Approved',
                isVerified: true,
            },
            include: { university: true, college: true },
        });
        return {
            message: 'Registered successfully',
            student: this.sanitizeStudent(student),
        };
    }
    async resetPassword(dto) {
        const id = dto.identifier.trim();
        const student = await this.prisma.student.findFirst({
            where: {
                OR: [
                    { email: id.toLowerCase() },
                    { hallTicket: id },
                    { mobile: id },
                ],
            },
        });
        if (!student) {
            throw new common_1.BadRequestException('No account found for the provided identifier');
        }
        const passwordHash = await bcrypt.hash(dto.newPassword, 10);
        await this.prisma.student.update({
            where: { id: student.id },
            data: { passwordHash },
        });
        return { message: 'Password reset successfully' };
    }
    sanitizeStudent(student) {
        const { passwordHash, ...rest } = student;
        return rest;
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map