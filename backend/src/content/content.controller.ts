import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { ContentService } from './content.service';

@ApiTags('Content & Feeds')
@Controller('api/content')
export class ContentController {
  constructor(private readonly contentService: ContentService) {}

  @Get('ticker')
  @ApiOperation({ summary: 'Get home screen announcement ticker text' })
  async getTicker() {
    return this.contentService.getTicker();
  }

  @Get('notifications')
  @ApiOperation({ summary: 'Get notification list' })
  async getNotifications() {
    return this.contentService.getNotifications();
  }

  @Get('results')
  @ApiOperation({ summary: 'Get exam result grades' })
  @ApiQuery({ name: 'branch', required: false, example: 'CSE' })
  @ApiQuery({ name: 'semester', required: false, example: 3 })
  async getResults(@Query('branch') branch?: string, @Query('semester') semester?: number) {
    return this.contentService.getResults(branch, semester);
  }

  @Get('internships')
  @ApiOperation({ summary: 'Get open internship opportunities' })
  @ApiQuery({ name: 'type', required: false })
  async getInternships(@Query('type') type?: string) {
    return this.contentService.getInternships(type);
  }
}
