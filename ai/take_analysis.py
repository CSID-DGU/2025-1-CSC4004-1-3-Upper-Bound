import cv2
import mediapipe as mp
import os
import numpy as np
import math

import pandas as pd
import matplotlib.pyplot as plt

from scipy.signal import find_peaks
from scipy.ndimage import gaussian_filter1d

# MediaPipe Pose 초기화
mp_pose = mp.solutions.pose # Pose 모듈 로딩
pose = mp_pose.Pose() # Pose 추정기 객체 생성
mp_drawing = mp.solutions.drawing_utils # 랜드마크 시각화

landmark_list = [] # landmark output

# 각도 저장할 리스트
elbow_angles = []
smooth_elbow = []

hip_angles = []
knee_angles = []
lower_body_alignment = []
elbow_x = []
upper_arm_lengths = []
forearm_lengths = []

shox = []
elbx = []
wrix = []

height1 = []

# 점수 지표
total_score = 0
top_position = []
bottom_position = []

avg_elbow_rom = 0
avg_lower_alignment = 0
# Pose landmarks 번호 (MediaPipe 기준)
LEFT_EYE = 2
LEFT_SHOULDER = 11
LEFT_ELBOW = 13
LEFT_WRIST = 15
LEFT_HIP = 23
LEFT_KNEE = 25
LEFT_ANKLE = 27
LEFT_HEEL = 29


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
            
        # 왼쪽 어깨, 팔꿈치, 손목만 빨간 점으로 덮어 그림
            h, w, _ = image.shape
            landmarks = results.pose_landmarks.landmark

            for idx in [LEFT_SHOULDER, LEFT_ELBOW, LEFT_WRIST]:
                cx, cy = int(landmarks[idx].x * w), int(landmarks[idx].y * h)
                cv2.circle(image, (cx, cy), 5, (0, 0, 255), -1)  # 빨간 점

            #list에 저장용
            for landmark in results.pose_landmarks.landmark:
                row.extend([landmark.x, landmark.y, landmark.z, landmark.visibility])
        else:
            if frame_idx-1 < 0:
                row.extend(frame_idx-1)
            else:
                row.extend([0.0] * 33 * 4)

        landmark_list.append(row)

        #실시간 영상 보여주기
        cv2.imshow('Pose Detection', image)
        frame_idx += 1

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    landmark_array = np.array(landmark_list)
    #print("Shape:", landmark_array.shape)
    #print("First 3 frames:\n", landmark_array[:3, :])

    cap.release()
    cv2.destroyAllWindows()

def calculate_angle(a, b, c):
    a = np.array(a) 
    b = np.array(b)
    c = np.array(c)

    # 벡터 구하기
    ba = a - b
    bc = c - b

    # 코사인 각도 계산
    cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
    angle = np.arccos(cosine_angle)  # 라디안
    return np.degrees(angle)  # degree로 변환

def calculate_distance(a, b):
    a = np.array(a)
    b = np.array(b)
    return np.linalg.norm(a - b)

def get_coord(row, idx):
    base = 1 + idx * 4
    return [row[base], row[base + 1], row[base + 2]]

def analysis():
    global smooth_elbow, bottom_position, top_position
    for idx, row in enumerate(landmark_list):
        shoulder = get_coord(row, LEFT_SHOULDER)
        elbow = get_coord(row, LEFT_ELBOW)
        wrist = get_coord(row, LEFT_WRIST)
        hip = get_coord(row, LEFT_HIP)
        knee = get_coord(row, LEFT_KNEE)
        ankle = get_coord(row, LEFT_ANKLE)
        eye = get_coord(row, LEFT_EYE)
        heel = get_coord(row, LEFT_HEEL)   
        #키
        height = calculate_distance(heel, eye)
        head = calculate_distance(shoulder, eye)
        height1.append(height+head)

        #전완과 팔꿈치 x 좌표 차이
        elbow_x.append(elbow[0]-wrist[0])
        #어깨 외전
        upper_arm = calculate_distance(shoulder, elbow)
        forearm = calculate_distance(elbow, wrist)
        upper_arm_lengths.append(upper_arm)
        forearm_lengths.append(forearm)

        shox.append(shoulder[0])
        elbx.append(elbow[0])
        wrix.append(wrist[0])

        #팔꿈치 가동범위
        elbow_angle = calculate_angle(shoulder, elbow, wrist)
        elbow_angles.append(elbow_angle)
        smooth_elbow = gaussian_filter1d(elbow_angles, sigma=2)

        #하체 정렬
        hip_angle = calculate_angle(shoulder, hip, knee)
        knee_angle = calculate_angle(hip, knee, ankle)
        hip_angles.append(hip_angle)
        knee_angles.append(knee_angle)
        lower_body_alignment.append(180-(hip_angle+knee_angle)/2)
    top_position, _ = find_peaks(smooth_elbow)
    bottom_position, _ = find_peaks(-smooth_elbow)
    avg_lower_alignment = (sum(lower_body_alignment) / len(lower_body_alignment))
    print(top_position)
    print(bottom_position)
    print(avg_lower_alignment)
        
def plot_joint_angles():
    frames = list(range(len(elbow_angles)))  # 프레임 번호 기준 x축

    plt.figure(figsize=(12, 6))

    plt.subplot(2, 2, 1)
    plt.plot(frames, elbow_x, color='green')
    plt.xlabel("Frame")
    plt.ylabel("pixel")
    plt.title("Elbow-Wrist aligment")
    plt.grid(True)

    plt.subplot(2, 2, 2)
    # plt.plot(frames, upper_arm_lengths, color='blue', label='upper')
    # plt.plot(frames, forearm_lengths, color='red', label='fore')
    plt.plot(frames, wrix, color='blue', label='wrist')
    plt.plot(frames, elbx, color='red', label='elbow')
    plt.plot(frames, shox, color='green', label='shol')
    plt.xlabel("Frame")
    plt.ylabel("Angle (°)")
    plt.title("Shoulder Abduction")
    plt.grid(True)
    plt.legend()

    plt.subplot(2, 2, 3)
    plt.plot(frames, smooth_elbow, color='blue')
    plt.scatter(top_position,[smooth_elbow[i] for i in top_position],color='y')
    plt.scatter(bottom_position,[smooth_elbow[i] for i in bottom_position],color='r')
    plt.xlabel("Frame")
    plt.ylabel("Angle (°)")
    plt.title("Elbow Angle")
    plt.grid(True)

    plt.subplot(2, 2, 4)
    plt.plot(frames, lower_body_alignment, color='green')
    plt.xlabel("Frame")
    plt.ylabel("Angle (°)")
    plt.title("Lowbody Aligment")
    plt.grid(True)

    # plt.subplot(2, 2, 4)
    # plt.plot(frames, height1, color='green')
    # plt.xlabel("Frame")
    # plt.ylabel("pixel")
    # plt.title("카")
    # plt.grid(True)


    plt.suptitle("Joint Angles Over Time")
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.show()

if __name__ == "__main__":
    video_path = os.path.join(os.getcwd(), "wide0.mp4")
    detect_and_display(video_path)
    analysis()
    plot_joint_angles()