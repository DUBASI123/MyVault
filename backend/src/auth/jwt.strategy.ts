import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'myvault-super-secret-key-2026',
    });
  }

  async validate(payload: { sub: string; role: string }) {
    const student = await this.prisma.student.findUnique({
      where: { id: payload.sub },
    });
    if (!student) {
      throw new UnauthorizedException('Invalid or expired token');
    }
    return student;
  }
}
