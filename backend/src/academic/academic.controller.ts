import { Controller, Get, Query, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { AcademicService } from './academic.service';

@ApiTags('Academic')
@Controller('api/academic')
export class AcademicController {
  constructor(private readonly academicService: AcademicService) {}

  @Get('subjects')
  @ApiOperation({ summary: 'Get curriculum subjects for branch and semester' })
  @ApiQuery({ name: 'branch', example: 'ECE' })
  @ApiQuery({ name: 'semester', example: 1 })
  @ApiQuery({ name: 'subjectType', required: false, example: 'academic' })
  async getSubjects(
    @Query('branch') branch: string,
    @Query('semester') semester: number,
    @Query('subjectType') subjectType?: string,
  ) {
    return this.academicService.getSubjects(branch, semester, subjectType);
  }

  @Get('contents/:subjectId')
  @ApiOperation({ summary: 'Get study contents for a specific subject' })
  async getContents(
    @Param('subjectId') subjectId: string,
    @Query('contentType') contentType?: string,
  ) {
    return this.academicService.getSubjectContents(subjectId, contentType);
  }
}
