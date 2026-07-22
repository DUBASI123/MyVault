"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var SmsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SmsService = void 0;
const common_1 = require("@nestjs/common");
let SmsService = SmsService_1 = class SmsService {
    constructor() {
        this.logger = new common_1.Logger(SmsService_1.name);
    }
    async sendSms(toMobile, message) {
        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        const fromPhone = process.env.TWILIO_PHONE_NUMBER;
        if (accountSid && authToken && fromPhone) {
            try {
                const client = require('twilio')(accountSid, authToken);
                await client.messages.create({
                    body: message,
                    from: fromPhone,
                    to: toMobile.startsWith('+') ? toMobile : `+91${toMobile}`,
                });
                this.logger.log(`SMS dispatched to ${toMobile} via Twilio`);
                return true;
            }
            catch (err) {
                this.logger.error(`Twilio SMS failed to ${toMobile}: ${err.message}`);
                return false;
            }
        }
        this.logger.log(`[MOCK SMS] To: ${toMobile} | Message: ${message}`);
        return true;
    }
};
exports.SmsService = SmsService;
exports.SmsService = SmsService = SmsService_1 = __decorate([
    (0, common_1.Injectable)()
], SmsService);
//# sourceMappingURL=sms.service.js.map