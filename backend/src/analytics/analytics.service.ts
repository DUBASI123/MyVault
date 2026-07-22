import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AnalyticsService {
  private readonly logger = new Logger(AnalyticsService.name);

  async logEvent(eventName: string, studentId?: string, params: Record<string, any> = {}) {
    this.logger.log(`[ANALYTICS] Event: ${eventName} | Student: ${studentId || 'Anonymous'} | Params: ${JSON.stringify(params)}`);
    // Datadog / Mixpanel / Amplitude event forwarder hook
    return { status: 'logged', eventName, timestamp: new Date().toISOString() };
  }
}
