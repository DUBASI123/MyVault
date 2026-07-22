import { AnalyticsService } from './analytics.service';
export declare class AnalyticsController {
    private readonly analyticsService;
    constructor(analyticsService: AnalyticsService);
    logEvent(eventName: string, studentId?: string, params?: Record<string, any>): Promise<{
        status: string;
        eventName: string;
        timestamp: string;
    }>;
}
