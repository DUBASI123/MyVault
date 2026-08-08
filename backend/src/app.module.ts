import { Module } from '@nestjs/common';
import { join } from 'path';
import { ServeStaticModule } from '@nestjs/serve-static';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { AuthModule } from './auth/auth.module';
import { AcademicModule } from './academic/academic.module';
import { ContentModule } from './content/content.module';
import { MasterModule } from './master/master.module';
import { StorageModule } from './storage/storage.module';
import { NotificationModule } from './notifications/notification.module';
import { PaymentsModule } from './payments/payments.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { EmailService } from './services/email.service';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', '..', 'public'),
      exclude: ['/api/(.*)', '/api/docs'],
    }),
    PrismaModule,
    RedisModule,
    AuthModule,
    AcademicModule,
    ContentModule,
    MasterModule,
    StorageModule,
    NotificationModule,
    PaymentsModule,
    AnalyticsModule,
  ],
  controllers: [AppController],
  providers: [EmailService],
  exports: [EmailService],
})
export class AppModule {}
