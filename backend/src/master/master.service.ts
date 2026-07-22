import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class MasterService {
  constructor(private prisma: PrismaService) {}

  async getUniversities() {
    return this.prisma.university.findMany({ orderBy: { name: 'asc' } });
  }

  async getColleges(universityId?: string) {
    return this.prisma.college.findMany({
      where: universityId ? { universityId } : undefined,
      orderBy: { name: 'asc' },
    });
  }
}
