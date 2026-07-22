export declare class SmsService {
    private readonly logger;
    sendSms(toMobile: string, message: string): Promise<boolean>;
}
