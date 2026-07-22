export declare class AnalyticsService {
    private readonly logger;
    logEvent(eventName: string, studentId?: string, params?: Record<string, any>): Promise<{
        status: string;
        eventName: string;
        timestamp: string;
    }>;
}
