"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var NotificationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationService = void 0;
const common_1 = require("@nestjs/common");
const admin = require("firebase-admin");
let NotificationService = NotificationService_1 = class NotificationService {
    constructor() {
        this.logger = new common_1.Logger(NotificationService_1.name);
        try {
            if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
                const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
                this.firebaseApp = admin.initializeApp({
                    credential: admin.credential.cert(serviceAccount),
                });
                this.logger.log('Firebase Admin SDK initialized successfully');
            }
        }
        catch (e) {
            this.logger.warn(`Firebase Admin SDK init skipped: ${e.message}`);
        }
    }
    async sendPushNotification(token, title, body, deepLink) {
        if (!this.firebaseApp)
            return;
        try {
            await admin.messaging().send({
                token,
                notification: { title, body },
                data: deepLink ? { deep_link: deepLink } : {},
            });
            this.logger.log(`Pushed notification to token: ${token.substring(0, 10)}...`);
        }
        catch (err) {
            this.logger.error(`FCM Push Error: ${err.message}`);
        }
    }
};
exports.NotificationService = NotificationService;
exports.NotificationService = NotificationService = NotificationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], NotificationService);
//# sourceMappingURL=notification.service.js.map