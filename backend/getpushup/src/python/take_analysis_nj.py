import json
import cv2
import mediapipe as mp
import os
import numpy as np
import math

import pandas as pd
import matplotlib.pyplot as plt

from scipy.signal import find_peaks
from scipy.ndimage import gaussian_filter1d

import sys

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
z_elbow =[]
z_shoulder =[]
z_wrist = []

shox = []
elbx = []
wrix = []

height1 = []

# 점수 지표
total_score = 0
top_position = []
bottom_position = []

max_elbow_alignment = 0
min_elbow_alignment = 0
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
LEFT_TOE = 31



def detect_and_display(video_path): # landmark 추출
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        error = {"error": f"Cannot open video {video_path}"}
        print(json.dumps(error))
        sys.exit(1)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)

    # fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # 🔺 추가됨
    # out = cv2.VideoWriter('output_pose.mp4', fourcc, fps, (width, height))
    # print("Saving to:", os.path.abspath('output_with_pose.mp4'))
    frame_idx = 0

    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            #print("End of video.")
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
                landmark = landmarks[idx]
                cx, cy = int(landmark.x * w), int(landmark.y * h)
                cz = landmark.z  # z는 상대적 깊이 정보 (단위: 대략 normalized scale)

                cv2.circle(image, (cx, cy), 5, (0, 0, 255), -1)  # 빨간 점

                # 소수점 3자리까지 z 좌표 포함해서 텍스트 출력
                coord_text = f"({cx}, {cy}, {cz:.3f})"
                cv2.putText(image, coord_text, (cx + 10, cy - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1, cv2.LINE_AA)

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
        #cv2.imshow('Pose Detection', image)
        # out.write(image)
        frame_idx += 1

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    landmark_array = np.array(landmark_list)
    #print("Shape:", landmark_array.shape)
    #print("First 3 frames:\n", landmark_array[:3, :])
    # out.release()
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
    global smooth_elbow, upper_arm_lengths, avg_elbow_rom, bottom_position, top_position

    mid_row = landmark_list[len(landmark_list) // 2]
    mid_wirst = get_coord(mid_row, LEFT_WRIST)
    for idx, row in enumerate(landmark_list):
        shoulder = get_coord(row, LEFT_SHOULDER)
        elbow = get_coord(row, LEFT_ELBOW)
        wrist = get_coord(row, LEFT_WRIST)
        hip = get_coord(row, LEFT_HIP)
        knee = get_coord(row, LEFT_KNEE)
        ankle = get_coord(row, LEFT_ANKLE)
        eye = get_coord(row, LEFT_EYE)
        heel = get_coord(row, LEFT_HEEL)   
        toe = get_coord(row, LEFT_TOE)  
        #키
        height = calculate_distance(heel, eye)
        head = calculate_distance(shoulder, eye)
        height1.append(height+head)

        #전완과 팔꿈치 x 좌표 차이
        elbow_x.append(calculate_angle(elbow[:2], mid_wirst[:2], [mid_wirst[0]+1,mid_wirst[1]]))
        #elbow_x.append(calculate_angle(elbow[:2], mid_wirst[:2], toe[:2]))
        #어깨 외전
        upper_arm = calculate_distance(shoulder[:2], elbow[:2])
        forearm = calculate_distance(elbow[:2], wrist[:2])
        upper_arm_lengths.append(upper_arm)
        forearm_lengths.append(forearm)

        z_elbow.append(elbow[2])
        z_shoulder.append(shoulder[2])
        z_wrist.append(wrist[2])

        shox.append(shoulder[0])
        elbx.append(elbow[0])
        wrix.append(wrist[0])

        #팔꿈치 가동범위
        elbow_angle = calculate_angle(shoulder[:2], elbow[:2], wrist[:2])
        elbow_angles.append(elbow_angle)
        

        #하체 정렬
        hip_angle = calculate_angle(shoulder[:2], hip[:2], knee[:2])
        knee_angle = calculate_angle(hip[:2], knee[:2], ankle[:2])
        hip_angles.append(hip_angle)
        knee_angles.append(knee_angle)
        lower_body_alignment.append(180-(hip_angle+knee_angle)/2)
    #상완 길이
    upper_arm_lengths = gaussian_filter1d(upper_arm_lengths, sigma=2)
    upper_arm_bottom, _ = find_peaks(-upper_arm_lengths)
    upper_arm_point = sum(upper_arm_lengths[upper_arm_bottom])/len(upper_arm_bottom)
    forearm_point = sum(forearm_lengths)/len(forearm_lengths)
    abduction_point = forearm_point/upper_arm_point
    #팔꿈치 정렬
    max_elbow_alignment = max(elbow_x)
    min_elbow_alignment = min(elbow_x)
    #팔꿈치 가동범위
    smooth_elbow = gaussian_filter1d(elbow_angles, sigma=2)
    top_position, _ = find_peaks(smooth_elbow)
    bottom_position, _ = find_peaks(-smooth_elbow)
    avg_elbow_rom = sum(smooth_elbow[top_position])/len(top_position)-sum(smooth_elbow[bottom_position])/len(bottom_position)
    #하체 정렬
    avg_lower_alignment = (sum(lower_body_alignment) / len(lower_body_alignment))
    # print(f"팔꿈치 정렬 각도 : 최대 {max_elbow_alignment} 최소 {min_elbow_alignment}")
    # print(f"어깨 외전 각도 : {abduction_point * 112.3605 - 177.2080}")
    # print(f"팔꿈치 가동범위 : {avg_elbow_rom}")
    # print(f"하체 정렬 : {avg_lower_alignment}")

    #점수
    pushup_count = len(bottom_position)
    result = {
    "pushup_count": pushup_count,
    "elbow_alignment": min_elbow_alignment,
    "abduction_angle": abduction_point * 112.3605 - 177.2080,
    "avg_elbow_rom": avg_elbow_rom,
    "avg_lower_alignment": avg_lower_alignment,
    "elbow_alignment_timeline": elbow_x,
    "elbow_rom_timeline": smooth_elbow.tolist(),
    "lower_alignment_timline": lower_body_alignment,
    }
    print(json.dumps(result))

        
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
    # plt.plot(frames, z_wrist, color='blue', label='wrist_Z')
    # plt.plot(frames, z_elbow, color='y', label='elbow_Z')
    # plt.plot(frames, z_shoulder, color='red', label='shoulder_Z')
    plt.plot(frames, upper_arm_lengths, color='blue', label='upper')
    plt.plot(frames, forearm_lengths, color='red', label='fore')
    # plt.plot(frames, wrix, color='blue', label='wrist')
    # plt.plot(frames, elbx, color='red', label='elbow')
    # plt.plot(frames, shox, color='green', label='shol')
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
    # plt.title("height")
    # plt.grid(True)

    plt.suptitle("Joint Angles Over Time")
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.show()

if __name__ == "__main__":
    
    if len(sys.argv) < 2:
        error = {"error": f" No video path provided"}
        print(json.dumps(error))
        sys.exit(1)
    else:
        #video_path = os.path.join(os.getcwd(), "wide0.mp4")
        video_path = sys.argv[1]
        detect_and_display(video_path)
        analysis()
        #plot_joint_angles()