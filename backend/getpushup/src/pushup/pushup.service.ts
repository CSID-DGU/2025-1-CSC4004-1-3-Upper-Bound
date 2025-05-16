import { Injectable } from '@nestjs/common';
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

  async analyzePushup(body: any) {
    const userId = Number(body.userId);

    const id = Date.now().toString(); // 임시 ID

    const result: PushupAnalysis = {
      id,
      createdAt: new Date(),
      repetition_count: 10,
      score: 87.2,
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
      userId,
    };

    this.analyses.push(result);

    return {
      analysisId: id,
    };
  }

  getAllAnalyses() {
    return this.analyses.map(({ id, createdAt, repetition_count, score }) => ({
      id,
      createdAt,
      repetition_count,
      score,
    }));
  }

  getAnalysisById(id: string) {
    return this.analyses.find((a) => a.id === id);
  }
}
