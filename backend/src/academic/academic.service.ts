import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class AcademicService {
  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
  ) {}

  async getSubjects(branch: string, semester: number, subjectType = 'academic') {
    const cacheKey = `subjects:${branch}:${semester}:${subjectType}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }

    const data = await this.prisma.subject.findMany({
      where: {
        branch: String(branch),
        semester: Number(semester),
        subjectType: String(subjectType),
      },
      orderBy: { name: 'asc' },
    });

    await this.redis.set(cacheKey, JSON.stringify(data), 600); // 10 min TTL
    return data;
  }

  async getSubjectContents(subjectId: string, contentType?: string) {
    return this.prisma.academicContent.findMany({
      where: {
        subjectId,
        ...(contentType && contentType !== 'all' ? { contentType: String(contentType) } : {}),
      },
      orderBy: { createdAt: 'desc' },
    });
  }
}
