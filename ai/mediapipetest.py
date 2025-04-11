import cv2
import mediapipe as mp
import os
import csv

# MediaPipe Pose 초기화
mp_pose = mp.solutions.pose
pose = mp_pose.Pose()
mp_drawing = mp.solutions.drawing_utils

def detect_and_save(video_path):
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        print(f"Error: Cannot open video {video_path}")
        return

    # 비디오 저장 설정
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # MPEG-4 코덱
    out = cv2.VideoWriter('output.mp4', fourcc, fps, (width, height))

    # CSV 파일 설정
    csv_file = open('landmarks.csv', mode='w', newline='')
    csv_writer = csv.writer(csv_file)

    # CSV 헤더 작성
    header = ['frame']
    for idx in range(33):  # 33개의 포즈 랜드마크 (mediapipe 기준)
        header += [f'x{idx}', f'y{idx}', f'z{idx}', f'visibility{idx}']
    csv_writer.writerow(header)

    frame_idx = 0

    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            print("End of video.")
            break

        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = pose.process(image)

        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

        row = [frame_idx]  # 현재 프레임 번호 기록

        if results.pose_landmarks:
            # 랜드마크 그리기
            mp_drawing.draw_landmarks(
                image,
                results.pose_landmarks,
                mp_pose.POSE_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(255, 0, 0), thickness=2, circle_radius=2)
            )
            # 랜드마크 좌표 저장
            for landmark in results.pose_landmarks.landmark:
                row.extend([landmark.x, landmark.y, landmark.z, landmark.visibility])
        else:
            # 랜드마크 못 찾으면 빈 값
            row.extend([None] * 33 * 4)

        csv_writer.writerow(row)

        # 영상 프레임 저장
        out.write(image)

        # 화면에 보여주기
        cv2.imshow('Pose Detection', image)

        frame_idx += 1

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    out.release()
    csv_file.close()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    video_path = os.path.join(os.getcwd(), "video.mp4")
    detect_and_save(video_path)