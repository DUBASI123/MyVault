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
    if (cached) return JSON.parse(cached);

    const data = await this.prisma.subject.findMany({
      where: {
        branch: String(branch),
        semester: Number(semester),
        subjectType: String(subjectType),
      },
      orderBy: { name: 'asc' },
    });

    await this.redis.set(cacheKey, JSON.stringify(data), 600);
    return data;
  }

  async getSubjectContents(subjectId: string, contentType?: string) {
    return this.prisma.academicContent.findMany({
      where: {
        subjectId,
        ...(contentType && contentType !== 'all' ? { contentType } : {}),
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createContent(dto: {
    subjectId: string;
    title: string;
    contentType: string;
    unitNumber?: number;
    fileUrl?: string;
    storagePath?: string;
    description?: string;
  }) {
    const content = await this.prisma.academicContent.create({
      data: {
        subjectId:   dto.subjectId,
        title:       dto.title,
        contentType: dto.contentType,
        unitNumber:  dto.unitNumber ?? null,
        fileUrl:     dto.fileUrl ?? null,
        storagePath: dto.storagePath ?? null,
        description: dto.description ?? null,
      },
    });

    // Bust cache for this subject
    const subject = await this.prisma.subject.findUnique({ where: { id: dto.subjectId } });
    if (subject) {
      await this.redis.del(`subjects:${subject.branch}:${subject.semester}:${subject.subjectType}`);
    }

    return content;
  }
}
