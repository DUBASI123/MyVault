import { Injectable, Logger } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private transporter: nodemailer.Transporter;

  constructor() {
    const host = process.env.SMTP_HOST || 'smtp.sendgrid.net';
    const port = Number(process.env.SMTP_PORT) || 587;
    const user = process.env.SMTP_USER || 'apikey';
    const pass = process.env.SMTP_PASS || process.env.SENDGRID_API_KEY || '';

    if (pass) {
      this.transporter = nodemailer.createTransport({
        host,
        port,
        secure: port === 465,
        auth: { user, pass },
      });
      this.logger.log(`Email Service initialized with host: ${host}`);
    } else {
      this.logger.warn('Email Service running in mock mode (No SMTP credentials configured)');
    }
  }

  async sendEmail(to: string, subject: string, html: string): Promise<boolean> {
    if (!this.transporter) {
      this.logger.log(`[MOCK EMAIL] To: ${to} | Subject: ${subject}`);
      return true;
    }

    try {
      await this.transporter.sendMail({
        from: process.env.EMAIL_FROM || '"MyVault Support" <noreply@myvault.app>',
        to,
        subject,
        html,
      });
      this.logger.log(`Transactional email sent to ${to}`);
      return true;
    } catch (err) {
      this.logger.error(`Failed to send email to ${to}: ${err.message}`);
      return false;
    }
  }
}
