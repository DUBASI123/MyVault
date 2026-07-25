import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor() {
    this.logger.log('Mock NotificationService initialized (Firebase disabled)');
  }

  async sendPushNotification(token: string, title: string, body: string, deepLink?: string) {
    this.logger.log(`Mock FCM Push (Firebase disabled): ${title} - ${body}`);
  }
}
