import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PushupAnalysis } from './pushup.entity';

@Injectable()
export class PushupService {
  private analyses: PushupAnalysis[] = [];

  getAnalysesLength(): number {
    return this.analyses.length;
  }

  async analyzePushup(body: any, userId : String) {
    const id = String(this.analyses.length);
    const result: PushupAnalysis = {
      id,
      userId: userId,
      createdAt: new Date(),
      repetition_count: body.pushup_count,
      score: body.total_score,
      summary: {
        elbow_motion: body.elbow_alignment,
        shoulder_abduction: body.abduction_angle,
        elbow_flexion: body.avg_elbow_rom,
        lower_body_alignment_score: body.avg_lower_alignment,
      },
      timeseries: {
        elbow_y: body.elbow_alignment_timeline,
        elbow_flexion: body.elbow_rom_timeline,
        lower_body_angle: body.lower_alignment_timline,
      },
    };

    this.analyses.push(result);

    return {
      analysisId: id,
    };
  }

  getAllAnalyses() {
    return this.analyses
      .map(({ id, createdAt, repetition_count, score }) => ({
        id,
        createdAt,
        repetition_count,
        score,
      }));
    }

  getAllAnalysesSummary() {
    return this.analyses
    .map(({id, userId, summary}) => ({
      id,
      userId,
      summary,
    }));
  }   // 모든 분석 결과 한번에 보기 위해 추가

  getAllAnalysesByUser(userId: String) {
  return this.analyses
    .filter(a => a.userId === userId)
    .map(({ id, createdAt, repetition_count, score }) => ({
      id,
      userId,
      createdAt,
      repetition_count,
      score,
    }));
  }

  getAnalysisById(analysisId: String) {
  const analysis = this.analyses.find((a) => a.id === analysisId);

  if (!analysis) {
    throw new NotFoundException('해당 분석 결과를 찾을 수 없습니다.');
  }
  return analysis;
  }

  deleteAnalysisById(analysisId: string) {
  const index = this.analyses.findIndex(a => a.id === analysisId);

  if (index === -1) {
    throw new NotFoundException('분석 결과를 찾을 수 없습니다.');
  }

  this.analyses.splice(index, 1);
  return { success: true, message: '삭제되었습니다.' };
  }
}
