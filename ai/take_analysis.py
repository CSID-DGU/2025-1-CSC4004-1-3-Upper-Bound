import cv2
import mediapipe as mp
import os
import numpy as np

# MediaPipe Pose 초기화
mp_pose = mp.solutions.pose # Pose 모듈 로딩
pose = mp_pose.Pose() # Pose 추정기 객체 생성
mp_drawing = mp.solutions.drawing_utils # 랜드마크 시각화

landmark_list = [] # landmark output

def detect_and_display(video_path): # landmark 추출
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        print(f"Error: Cannot open video {video_path}")
        return

    frame_idx = 0

    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            print("End of video.")
            break

        # BGR(기본 OpenCV 포맷) → RGB (MediaPipe는 RGB 사용)
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False # 성능 향상을 위해 읽기 전용 설정
        results = pose.process(image)

        image.flags.writeable = True # 다시 쓰기 가능하게 변경
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR) # 다시 BGR로 변환

        row = [frame_idx]  # 현재 프레임 번호

        if results.pose_landmarks: # 포즈가 감지된 경우
            # landmark 그리기
            mp_drawing.draw_landmarks( 
                image,
                results.pose_landmarks,
                mp_pose.POSE_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(255, 0, 0), thickness=2, circle_radius=2)
            )
            #list에 저장용
            for landmark in results.pose_landmarks.landmark:
                row.extend([landmark.x, landmark.y, landmark.z, landmark.visibility])
        else:
            row.extend([None] * 33 * 4)

        landmark_list.append(row)

        #실시간 영상 보여주기
        cv2.imshow('Pose Detection', image)
        frame_idx += 1

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    landmark_array = np.array(landmark_list)
    print("Shape:", landmark_array.shape)
    print("First 3 frames:\n", landmark_array[:3, :])

    cap.release()
    cv2.destroyAllWindows()

def analysis():
    None

if __name__ == "__main__":
    video_path = os.path.join(os.getcwd(), "video.mp4")
    detect_and_display(video_path)
    analysis()