import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);

  onModuleInit() {
    this.logger.log('Mock Redis client initialized');
  }

  async onModuleDestroy() {}

  async get(key: string): Promise<string | null> {
    return null;
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {}

  async del(key: string): Promise<void> {}
}
