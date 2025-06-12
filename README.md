# 2025-1-CSC4004-1-3-Upper-Bound

### AI 맨몸운동 자세 분석 앱, **Upper Bound**
---

### 🧑‍🤝‍🧑 구성원  
|서한유|강세희|송유진|우승민|배인호|
| :---------: | :---------: | :---------: | :---------: | :---------: |
|멀티미디어<br>소프트웨어공학전공|컴퓨터공학전공|컴퓨터공학전공|컴퓨터공학전공|멀티미디어<br>소프트웨어공학전공|
|TL/BE|FE |FE| BE|BE|
| <img src="https://github.com/hu5768.png" width="100"> | <img src="https://github.com/ehsui.png" width="100"> | <img src="https://github.com/Son9YuJin.png" width="100"> | <img src="https://github.com/SeungMin-Woo.png" width="100"> |<img src="https://github.com/BAE-INHO.png" width="100"> |
|        [@hu5768](https://github.com/hu5768)       |         [@ehsui](https://github.com/ehsui)        |        [@Son9YuJin](https://github.com/Son9YuJin)        |        [@SeungMin-Woo](https://github.com/SeungMin-Woo)|[@BAE-INHO](https://github.com/BAE-INHO)|

## 🛠️ 사용 기술 및 라이브러리

<div align=center><h2>STACKS</h2></div>

<div align=center> 
  <img src="https://img.shields.io/badge/nestjs-E0234E?style=for-the-badge&logo=nestjs&logoColor=white">
  <img src="https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <br>
  <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white">
  <img src="https://img.shields.io/badge/git-F05032?style=for-the-badge&logo=git&logoColor=white">
  <img src="https://img.shields.io/badge/notion-000000?style=for-the-badge&logo=notion&logoColor=white">
  <br>
</div>

- **AI 라이브러리**:
  - `matplotlib==3.10.1`
  - `mediapipe==0.10.21`
  - `numpy==1.26.4`
  - `opencv-python==4.11.0.86`
  - `scipy==1.15.2`

---

## 1. 서비스 개요

맨몸운동(푸쉬업, 풀업)의 자세를 분석하여 스스로 자신의 자세를 인지하고 교정할 수 있도록 도와주는 앱입니다.


---
## 2. 주요 기능
### 🔍 푸쉬업 측면 자세 분석
- 분석 지표:
  - 팔꿈치 움직임
    - 지표면과 전완의 각도가 80~100 사이를 표준 각도로 판단하고 80 이하면 팔꿈치 부하, 100 이상이면 손목과 어깨의 부하가 커지는 것으로 판단
  - 어깨의 외전 각도
    - 푸시업 도중 어깨의 외전 각도에 따라 45~60을 정상 범위 45 이하 손목 부하, 60 이상 어깨 불안정성 증가가 나타나는 것으로 판단
  - 팔꿈치 가동 범위
    - 팔꿈치가 약 55°까지 굽혀졌을 때 전거근의 근전도 활동이 가장 높게 나타나 전거근을 강화하기 위해서는 해당 각도의 운동이 효과적
    -  최소한 80을 넘기면 일반적인 가동범위로 판단
  - 하체 정렬
    - 무릎의 굴곡 정도 20 기준으로 판단, 일직선으로 유지하는 것이 좋은 푸시업 지표

---
## 3. branch 구조 및 작업 방법
<img width="631" alt="image" src="https://github.com/user-attachments/assets/6dacc76b-f3a5-490d-b334-3893cf246995" />
---


