import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  Get,
  Param,
  UseGuards,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { PushupService } from './pushup.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('pushup')
export class PushupController {
  constructor(private readonly pushupService: PushupService) {}

  @Post('calibration')
  @UseInterceptors(FileInterceptor('file'))
  async calibrate(@UploadedFile() file: any) {
    return this.pushupService.calibrate(file);
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  async upload(@UploadedFile() file: any, @Body() body: any) {
    return this.pushupService.analyzePushup(file, body);
  }

  @Get('analytics')
  @UseGuards(AuthGuard)
  getAnalyticsList() {
    return this.pushupService.getAllAnalyses();
  }

  @Get('analytics/:id')
  @UseGuards(AuthGuard)
  getAnalyticsDetail(@Param('id') id: string) {
    return this.pushupService.getAnalysisById(id);
  }
}