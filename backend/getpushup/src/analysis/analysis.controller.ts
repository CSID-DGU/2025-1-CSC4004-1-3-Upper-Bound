import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { AnalysisService } from './analysis.service';
import { CreateAnalysisDto } from './dto/create-analysis.dto';
import { UpdateAnalysisDto } from './dto/update-analysis.dto';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);


@Controller('analysis')
export class AnalysisController {
  constructor(private readonly analysisService: AnalysisService) {}

  @Get()
  async getDouble(@Query('value') value: string): Promise<string> {
    if (!value) return 'Missing value';
    
    try {
      const { stdout } = await execAsync(`python3 src/test.py ${value}`);
      return stdout.trim(); // 결과의 줄바꿈 제거
    } catch (error) {
      return `Error: ${error.message}`;
    }
  }

  @Post()
  create(@Body() createAnalysisDto: CreateAnalysisDto) {
    return this.analysisService.create(createAnalysisDto);
  }

  @Get()
  findAll() {
    return this.analysisService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.analysisService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateAnalysisDto: UpdateAnalysisDto) {
    return this.analysisService.update(+id, updateAnalysisDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.analysisService.remove(+id);
  }
}
