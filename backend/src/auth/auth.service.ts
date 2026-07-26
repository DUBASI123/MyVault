import { Injectable, UnauthorizedException, BadRequestException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async login(dto: LoginDto) {
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
      throw new UnauthorizedException('Invalid credentials');
    }

    const valid = await bcrypt.compare(dto.password, student.passwordHash);
    if (!valid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { sub: student.id, role: student.role };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '30d' });
    const supabaseToken = this.jwtService.sign(
      {
        sub: student.id,
        role: 'authenticated',
        aud: 'authenticated',
      },
      { expiresIn: '7d' },
    );

    return {
      token: accessToken,
      accessToken,
      supabaseToken,
      refreshToken,
      student: this.sanitizeStudent(student),
    };
  }

  async register(dto: RegisterDto) {
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
      throw new ConflictException('Email, mobile, or hall ticket already registered');
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

  async resetPassword(dto: ResetPasswordDto) {
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
      throw new BadRequestException('No account found for the provided identifier');
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, 10);
    await this.prisma.student.update({
      where: { id: student.id },
      data: { passwordHash },
    });

    return { message: 'Password reset successfully' };
  }

  private sanitizeStudent(student: any) {
    const { passwordHash, ...rest } = student;
    return rest;
  }
}
