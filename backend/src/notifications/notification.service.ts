import { Injectable, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);
  private firebaseApp: admin.app.App;

  constructor() {
    try {
      if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        this.logger.log('Firebase Admin SDK initialized successfully');
      }
    } catch (e) {
      this.logger.warn(`Firebase Admin SDK init skipped: ${e.message}`);
    }
  }

  async sendPushNotification(token: string, title: string, body: string, deepLink?: string) {
    if (!this.firebaseApp) return;
    try {
      await admin.messaging().send({
        token,
        notification: { title, body },
        data: deepLink ? { deep_link: deepLink } : {},
      });
      this.logger.log(`Pushed notification to token: ${token.substring(0, 10)}...`);
    } catch (err) {
      this.logger.error(`FCM Push Error: ${err.message}`);
    }
  }
}
