export class PushupAnalysis {
    id: string;
    createdAt: Date;
    repetition_count: number;
    score: number;
  
    summary: {
      elbow_motion: number;
      shoulder_abduction: number;
      elbow_flexion: {
        min: number;
        max: number;
      };
      lower_body_alignment_score: number;
    };
  
    timeseries: {
      elbow_y: number[];
      shoulder_abduction: number[];
      elbow_flexion: number[];
      lower_body_angle: number[];
    };
  }