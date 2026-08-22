import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as compression from 'compression';
import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);

  // Enable Gzip/Brotli response compression for ultra-fast API payloads
  app.use(compression());

  // Enable CORS with full method support for web & mobile presigned URL uploads
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: ['Content-Type', 'Accept', 'Authorization', 'x-upsert', 'range'],
    exposedHeaders: ['Content-Length', 'Content-Range', 'ETag'],
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  // Swagger OpenAPI Configuration
  const config = new DocumentBuilder()
    .setTitle('MyVault NestJS REST API')
    .setDescription('Enterprise Production API — Auth, Academic, Content, S3 & Push Notifications')
    .setVersion('1.1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 5000;
  await app.listen(port, '0.0.0.0');

  logger.log(`🚀 MyVault NestJS Server running on http://0.0.0.0:${port}`);
  logger.log(`📚 Swagger OpenAPI Documentation live at http://localhost:${port}/api/docs`);
}

bootstrap();
