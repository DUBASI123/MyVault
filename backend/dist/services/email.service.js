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
var EmailService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmailService = void 0;
const common_1 = require("@nestjs/common");
const nodemailer = require("nodemailer");
let EmailService = EmailService_1 = class EmailService {
    constructor() {
        this.logger = new common_1.Logger(EmailService_1.name);
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
        }
        else {
            this.logger.warn('Email Service running in mock mode (No SMTP credentials configured)');
        }
    }
    async sendEmail(to, subject, html) {
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
        }
        catch (err) {
            this.logger.error(`Failed to send email to ${to}: ${err.message}`);
            return false;
        }
    }
};
exports.EmailService = EmailService;
exports.EmailService = EmailService = EmailService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], EmailService);
//# sourceMappingURL=email.service.js.map