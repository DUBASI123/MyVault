import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);

  async sendSms(toMobile: string, message: string): Promise<boolean> {
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
      } catch (err) {
        this.logger.error(`Twilio SMS failed to ${toMobile}: ${err.message}`);
        return false;
      }
    }

    this.logger.log(`[MOCK SMS] To: ${toMobile} | Message: ${message}`);
    return true;
  }
}
