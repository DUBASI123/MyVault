export declare class NotificationService {
    private readonly logger;
    private firebaseApp;
    constructor();
    sendPushNotification(token: string, title: string, body: string, deepLink?: string): Promise<void>;
}
