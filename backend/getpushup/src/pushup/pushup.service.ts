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

  async analyzePushup(file: any, body: any) {
    const calibration = JSON.parse(body.calibration || '{}');

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
    };

    this.analyses.push(result);

    return {
      analysisId: id,
      summary: result.summary,
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
