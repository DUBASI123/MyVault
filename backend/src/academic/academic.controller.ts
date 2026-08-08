import { Controller, Get, Post, Body, Query, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBody } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, Min, Max } from 'class-validator';
import { AcademicService } from './academic.service';

export class CreateContentDto {
  @IsString() subjectId: string;
  @IsString() title: string;
  @IsString() contentType: string;
  @IsOptional() @IsInt() unitNumber?: number;
  @IsOptional() @IsString() fileUrl?: string;
  @IsOptional() @IsString() storagePath?: string;
  @IsOptional() @IsString() description?: string;
}

@ApiTags('Academic Hub')
@Controller('api/academic')
export class AcademicController {
  constructor(private readonly academicService: AcademicService) {}

  @Get('subjects')
  @ApiOperation({ summary: 'Get subjects by branch and semester' })
  @ApiQuery({ name: 'branch', required: true, example: 'ECE' })
  @ApiQuery({ name: 'semester', required: true, example: 1 })
  @ApiQuery({ name: 'type', required: false, example: 'academic' })
  async getSubjects(
    @Query('branch') branch: string,
    @Query('semester') semester: string,
    @Query('type') subjectType: string = 'academic',
  ) {
    return this.academicService.getSubjects(branch, parseInt(semester), subjectType);
  }

  @Get('subjects/:id/contents')
  @ApiOperation({ summary: 'Get all contents for a subject' })
  @ApiQuery({ name: 'type', required: false, description: 'Filter by content type' })
  async getSubjectContents(
    @Param('id') subjectId: string,
    @Query('type') contentType?: string,
  ) {
    return this.academicService.getSubjectContents(subjectId, contentType);
  }

  @Post('contents')
  @ApiOperation({ summary: 'Create academic content record (called after S3 upload)' })
  @ApiBody({ type: CreateContentDto })
  async createContent(@Body() dto: CreateContentDto) {
    return this.academicService.createContent(dto);
  }
}
