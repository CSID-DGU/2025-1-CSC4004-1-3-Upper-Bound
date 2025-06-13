import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import math

# 각도 계산 함수
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

# CSV 파일 불러오기
df = pd.read_csv('landmarks.csv')

# 각도 저장할 리스트
elbow_angles = []
hip_angles = []
knee_angles = []
elbow_x = []

upper_arm_lengths = []
forearm_lengths = []
# Pose landmarks 번호 (MediaPipe 기준)
LEFT_SHOULDER = 11
LEFT_ELBOW = 13
LEFT_WRIST = 15
LEFT_HIP = 23
LEFT_KNEE = 25
LEFT_ANKLE = 27

for idx, row in df.iterrows():
    try:
        # --- 팔꿈치 각도 계산 ---
        shoulder = [row[f'x{LEFT_SHOULDER}'], row[f'y{LEFT_SHOULDER}'], row[f'z{LEFT_SHOULDER}']]
        elbow = [row[f'x{LEFT_ELBOW}'], row[f'y{LEFT_ELBOW}'], row[f'z{LEFT_ELBOW}']]
        wrist = [row[f'x{LEFT_WRIST}'], row[f'y{LEFT_WRIST}'], row[f'z{LEFT_WRIST}']]

        if None not in shoulder and None not in elbow and None not in wrist:
            elbow_angle = calculate_angle(shoulder, elbow, wrist)
            elbow_angles.append(elbow_angle)
        else:
            elbow_angles.append(None)

        # --- 엉덩이 각도 계산 (어깨-엉덩이-무릎) ---
        shoulder_for_hip = [row[f'x{LEFT_SHOULDER}'], row[f'y{LEFT_SHOULDER}'], row[f'z{LEFT_SHOULDER}']]
        hip = [row[f'x{LEFT_HIP}'], row[f'y{LEFT_HIP}'], row[f'z{LEFT_HIP}']]
        knee = [row[f'x{LEFT_KNEE}'], row[f'y{LEFT_KNEE}'], row[f'z{LEFT_KNEE}']]

        if None not in shoulder_for_hip and None not in hip and None not in knee:
            hip_angle = calculate_angle(shoulder_for_hip, hip, knee)
            hip_angles.append(hip_angle)
        else:
            hip_angles.append(None)

        # --- 무릎 각도 계산 (엉덩이-무릎-발목) ---
        ankle = [row[f'x{LEFT_ANKLE}'], row[f'y{LEFT_ANKLE}'], row[f'z{LEFT_ANKLE}']]

        if None not in hip and None not in knee and None not in ankle:
            knee_angle = calculate_angle(hip, knee, ankle)
            knee_angles.append(knee_angle)
        else:
            knee_angles.append(None)

    except:
        elbow_angles.append(None)
        hip_angles.append(None)
        knee_angles.append(None)

for idx, row in df.iterrows():
    try:
        shoulder = [row[f'x{LEFT_SHOULDER}'], row[f'y{LEFT_SHOULDER}'], row[f'z{LEFT_SHOULDER}']]
        elbow = [row[f'x{LEFT_ELBOW}'], row[f'y{LEFT_ELBOW}'], row[f'z{LEFT_ELBOW}']]
        wrist = [row[f'x{LEFT_WRIST}'], row[f'y{LEFT_WRIST}'], row[f'z{LEFT_WRIST}']]

        if None not in shoulder and None not in elbow and None not in wrist:
            # 상완 길이 = 어깨 - 팔꿈치
            upper_arm = calculate_distance(shoulder, elbow)
            # 전완 길이 = 팔꿈치 - 손목
            forearm = calculate_distance(elbow, wrist)

            upper_arm_lengths.append(upper_arm)
            forearm_lengths.append(forearm)
            elbow_x.append(row[f'x{LEFT_ELBOW}'])
        else:
            upper_arm_lengths.append(None)
            forearm_lengths.append(None)

    except:
        upper_arm_lengths.append(None)
        forearm_lengths.append(None)


# 프레임 번호 만들기
frames = list(range(len(elbow_angles)))

# 그래프 그리기
plt.figure(figsize=(12, 6))
#plt.plot(frames, elbow_angles, label='Elbow Angle')
plt.plot(frames, elbow_x, label='Elbow X')
sum_angles = 360 - (np.array(hip_angles) + np.array(knee_angles))
#plt.plot(frames, sum_angles/2, label='Hip lower_body_angles')
#plt.plot(frames, knee_angles, label='Knee Angle')

#plt.plot(frames, upper_arm_lengths, label='upper arm')
#plt.plot(frames, forearm_lengths, label='forearm')
plt.legend()
plt.title('Left Angle Over Time')
plt.xlabel('Frame')
plt.ylabel('Angle (degrees)')
plt.grid()
plt.show()