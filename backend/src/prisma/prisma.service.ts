import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super({
      log: [
        { emit: 'event', level: 'query' },
        { emit: 'stdout', level: 'error' },
        { emit: 'stdout', level: 'warn' },
      ],
      errorFormat: 'pretty',
    });
  }

  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('✅ Connected to AWS RDS PostgreSQL');
    } catch (err) {
      this.logger.warn(`⚠️ AWS RDS PostgreSQL connection pending or failed: ${err.message}`);
      this.logger.warn('Server will continue running. Update DATABASE_URL in Render dashboard when RDS is ready.');
    }
  }

  async onModuleDestroy() {
    try {
      await this.$disconnect();
      this.logger.log('🔌 Disconnected from AWS RDS');
    } catch (_) {}
  }
}
