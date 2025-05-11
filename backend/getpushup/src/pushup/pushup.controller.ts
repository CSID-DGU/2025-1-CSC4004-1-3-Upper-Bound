import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  Get,
  Param,
  UseGuards,
  Req,
  Delete,
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
  getAnalyticsList(@Req() req) {
  return this.pushupService.getAllAnalysesByUser(req.user.userId);
  }

  @Get('analytics/:id')
  @UseGuards(AuthGuard)
  getAnalyticsDetail(@Param('id') id: string, @Req() req) {
  return this.pushupService.getAnalysisByIdForUser(id, req.user.userId);
  }

  @Delete('analytics/:id')
  @UseGuards(AuthGuard)
  deleteAnalysis(@Param('id') id: string, @Req() req) {
  return this.pushupService.deleteAnalysisById(id, req.user.userId);
  }
}