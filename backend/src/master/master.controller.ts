import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { MasterService } from './master.service';

@ApiTags('Master Data')
@Controller('api/master')
export class MasterController {
  constructor(private readonly masterService: MasterService) {}

  @Get('universities')
  @ApiOperation({ summary: 'Get list of universities' })
  async getUniversities() {
    return this.masterService.getUniversities();
  }

  @Get('colleges')
  @ApiOperation({ summary: 'Get list of colleges' })
  async getColleges(@Query('universityId') universityId?: string) {
    return this.masterService.getColleges(universityId);
  }
}
