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
import { diskStorage } from 'multer';
import { extname } from 'path';
import { exec } from 'child_process';
import * as util from 'util';
import { PushupService } from './pushup.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('pushup')
export class PushupController {
  constructor(private readonly pushupService: PushupService) {}

  @Post('analysis')
  @UseInterceptors(
    FileInterceptor('video', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, unique + extname(file.originalname));
        },
      }),
    }),
  )
  async uploadAndRunPython(@UploadedFile() file: Express.Multer.File) {
    const videoPath = file.path;
    const execPromise = util.promisify(exec);
    const pythonPath = '/Users/seohanyu/Documents/GitHub/DGUopenSW/2025-1-CSC4004-1-3-Upper-Bound/ai/aipy/bin/python';
    try {
      // Python 파일 실행 (예: process_video.py)
      const { stdout, stderr } = await execPromise(`${pythonPath} src/python/take_analysis_nj.py "${videoPath}"`);
      if (stderr) {
        console.error('Python error:', stderr);
      }

      return { message: '분석 완료', output: stdout.trim() };
    } catch (err) {
      console.error('실행 실패:', err);
      return { message: '실패', error: err };
    }
  }

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