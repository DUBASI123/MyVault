export declare class EmailService {
    private readonly logger;
    private transporter;
    constructor();
    sendEmail(to: string, subject: string, html: string): Promise<boolean>;
}
