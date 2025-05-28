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
  BadRequestException,
  Query,
  Res,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { exec } from 'child_process';
import * as util from 'util';
import { PushupService } from './pushup.service';
import { Response } from 'express';
import { createReadStream, existsSync } from 'fs';
import { join } from 'path';

@Controller('pushup')
export class PushupController {
  constructor(private readonly pushupService: PushupService) {}

  @Post('upload')
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
  async uploadAndRunPython(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: { userId: string },) {
    if (!body.userId) {
      throw new BadRequestException('userId는 필수입니다.');
    }
    const analysisId = String(this.pushupService.getAnalysesLength());
    const videoPath = file.path;
    const execPromise = util.promisify(exec);
    //const pythonPath = '/Users/seohanyu/Documents/GitHub/DGUopenSW/2025-1-CSC4004-1-3-Upper-Bound/ai/aipy/bin/python';
    //const pythonPath = 'C:/Users/wsm02/OSS-Project/aipy/Scripts/python';
    const pythonPath = '/usr/bin/python3.10'    // python 3.10버전으로 실행(서버용)
    try {
      const { stdout, stderr } = await execPromise(`${pythonPath} src/python/take_analysis_nj.py "${videoPath}" "${analysisId}"`);
      if (stderr) { 
        console.error('Python error:', stderr);
      }
      const result = JSON.parse(stdout);

      return this.pushupService.analyzePushup(result,body.userId);
    } catch (err) {
      console.error('실행 실패:', err);
      return { message: '실패', error: err };
    }
  }

  @Get('analytics/all')
  getAnalyticsList() {
  return this.pushupService.getAllAnalyses();
  }

  @Get('analytics/allsummary')
  getAllSummary() {
  return this.pushupService.getAllAnalysesSummary();

  }

  @Get('analytics')
  getAnalytics(
    @Query('userId') userId?: string,
    @Query('analysisId') analysisId?: string,
  ) {
    if (userId) {
      return this.pushupService.getAllAnalysesByUser(userId);
    } else if (analysisId) {
      return this.pushupService.getAnalysisById(analysisId);
    } else {
      throw new BadRequestException('userId 또는 analysisId 중 하나는 필요합니다.');
    }
  }

  @Delete('analytics/:analysisId')
  deleteAnalysis(@Param('analysisId') id: string) {
  return this.pushupService.deleteAnalysisById(id);

  }
  
  @Get('video/:analysisId')
  async streamVideo(@Param('analysisId') analysisId: string, @Res() res: Response) {
  const videoPath = join(__dirname, '..', '..', 'output_video', `output${analysisId}.mp4`);

  if (!existsSync(videoPath)) {
    return res.status(404).send('Video not found');
  }

  const stream = createReadStream(videoPath);
  res.setHeader('Content-Type', 'video/mp4');
  stream.pipe(res);
  }
}