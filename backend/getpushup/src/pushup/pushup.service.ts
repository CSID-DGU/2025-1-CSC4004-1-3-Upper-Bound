import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PushupAnalysis } from './pushup.entity';

@Injectable()
export class PushupService {
  private analyses: PushupAnalysis[] = [];

  async calibrate(file: any) {
    return {
      upper_arm_length: 33.4,
      forearm_length: 27.8,
      filename: file.originalname,
    };
  }

  async analyzePushup(file: any, body: any) {
    const calibration = JSON.parse(body.calibration || '{}');
    const userId = Number(body.userId);

    const id = Date.now().toString(); // 임시 ID

    const result: PushupAnalysis = {
      id,
      createdAt: new Date(),
      repetition_count: 10,
      score: 87.2,
      summary: {
        elbow_motion: 15.3,
        shoulder_abduction: 43.2,
        elbow_flexion: { min: 54, max: 172 },
        lower_body_alignment_score: 91.8,
      },
      timeseries: {
        elbow_y: [0.1, 0.2, 0.3],
        shoulder_abduction: [40, 42, 43],
        elbow_flexion: [160, 150, 130],
        lower_body_angle: [180, 177, 174],
      },
      userId,
    };

    this.analyses.push(result);

    return {
      analysisId: id,
      summary: result.summary,
    };
  }

  getAllAnalysesByUser(userId: number) {
  return this.analyses
    .filter(a => a.userId === userId)
    .map(({ id, createdAt, repetition_count, score }) => ({
      id,
      createdAt,
      repetition_count,
      score,
    }));
  }

  getAnalysisByIdForUser(id: string, userId: number) {
  const analysis = this.analyses.find((a) => a.id === id);

  if (!analysis) {
    throw new NotFoundException('해당 분석 결과를 찾을 수 없습니다.');
  }

  if (analysis.userId !== userId) {
    throw new ForbiddenException('접근 권한이 없습니다.');
  }

  return analysis;
  }

  deleteAnalysisById(id: string, userId: number) {
  const index = this.analyses.findIndex(a => a.id === id);

  if (index === -1) {
    throw new NotFoundException('분석 결과를 찾을 수 없습니다.');
  }

  if (this.analyses[index].userId !== userId) {
    throw new ForbiddenException('삭제 권한이 없습니다.');
  }

  this.analyses.splice(index, 1);
  return { success: true, message: '삭제되었습니다.' };
  }
}
