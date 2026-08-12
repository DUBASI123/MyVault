import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBody } from '@nestjs/swagger';
import { IsString, IsOptional } from 'class-validator';
import { ContentService } from './content.service';

export class CreateInternshipDto {
  @IsString() title: string;
  @IsString() company: string;
  @IsString() type: string; // IT | Core | Govt
  @IsOptional() @IsString() link?: string;
}

export class CreateNotificationDto {
  @IsString() title: string;
  @IsString() message: string;
  @IsOptional() @IsString() category?: string;
}

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

  @Post('notifications')
  @ApiOperation({ summary: 'Create new notification alert' })
  @ApiBody({ type: CreateNotificationDto })
  async createNotification(@Body() dto: CreateNotificationDto) {
    return this.contentService.createNotification(dto);
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

  @Post('internships')
  @ApiOperation({ summary: 'Create new placement drive or internship listing' })
  @ApiBody({ type: CreateInternshipDto })
  async createInternship(@Body() dto: CreateInternshipDto) {
    return this.contentService.createInternship(dto);
  }
}
