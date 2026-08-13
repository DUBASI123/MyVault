import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class ContentService {
  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
  ) {}

  async getTicker() {
    const cached = await this.redis.get('content:ticker');
    if (cached) return JSON.parse(cached);

    const items = await this.prisma.notification.findMany({
      orderBy: { createdAt: 'desc' },
      take: 5,
    });
    const ticker = items.length
      ? items.map((n) => `🔔 ${n.title}`).join(' | ')
      : 'Welcome to MyVault — your student platform';

    const result = { ticker };
    await this.redis.set('content:ticker', JSON.stringify(result), 300);
    return result;
  }

  async getNotifications() {
    return this.prisma.notification.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async createNotification(data: { title: string; message: string; category?: string }) {
    const notice = await this.prisma.notification.create({
      data: {
        title: data.title,
        message: data.message,
        type: data.category || 'general',
      },
    });
    await this.redis.del('content:ticker');
    return notice;
  }

  async getResults(branch?: string, semester?: number) {
    return this.prisma.examResult.findMany({
      where: {
        ...(branch ? { branch } : {}),
        ...(semester ? { semester: Number(semester) } : {}),
      },
      orderBy: { subject: 'asc' },
    });
  }

  async getInternships(type?: string) {
    return this.prisma.internship.findMany({
      where: type ? { type } : undefined,
      orderBy: { createdAt: 'desc' },
    });
  }

  async createInternship(data: { title: string; company: string; type: string; link?: string }) {
    return this.prisma.internship.create({
      data: {
        role: data.title,
        company: data.company,
        type: data.type || 'IT',
        applyLink: data.link || '',
      },
    });
  }
}
