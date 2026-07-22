import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AnalyticsService } from './analytics.service';

@ApiTags('Analytics & Telemetry')
@Controller('api/analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Post('event')
  @ApiOperation({ summary: 'Track user interaction event (Mixpanel / Amplitude / Firebase)' })
  async logEvent(
    @Body('eventName') eventName: string,
    @Body('studentId') studentId?: string,
    @Body('params') params?: Record<string, any>,
  ) {
    return this.analyticsService.logEvent(eventName, studentId, params);
  }
}
