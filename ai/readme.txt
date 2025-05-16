가상환경 생성
python3.10 --version
python3.10 -m venv aipy
python 3.10.17


가상환경 실행
source aipy/bin/activate

python -m venv aipy
source aipy/bin/activate   # (또는 윈도우는 aipy\Scripts\activate)
pip install -r requirements.txt  #라이브러리 설치

가상환경 스팩갱신
pip freeze > requirements.txt