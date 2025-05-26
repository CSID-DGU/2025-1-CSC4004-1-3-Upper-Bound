
export class PushupAnalysis {
  id: String;
  userId: String;
  createdAt: Date;
  repetition_count: number;
  score: number;

  summary: {
    elbow_motion: number;
    shoulder_abduction: number;
    elbow_flexion: number;
    lower_body_alignment_score: number;
  };

  timeseries: {
    elbow_y: number[];
    elbow_flexion: number[];
    lower_body_angle: number[];
  };

}