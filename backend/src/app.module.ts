import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { AuthModule } from './auth/auth.module';
import { AcademicModule } from './academic/academic.module';
import { ContentModule } from './content/content.module';
import { MasterModule } from './master/master.module';
import { StorageModule } from './storage/storage.module';
import { NotificationModule } from './notifications/notification.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    RedisModule,
    AuthModule,
    AcademicModule,
    ContentModule,
    MasterModule,
    StorageModule,
    NotificationModule,
  ],
})
export class AppModule {}
