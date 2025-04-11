가상환경 생성
python3.10 --version
python3.10 -m venv aipy



가상환경 실행
source aipy/bin/activate

python -m venv aipy
source aipy/bin/activate   # (또는 윈도우는 aipy\Scripts\activate)
pip install -r requirements.txt

가상환경 스팩
pip freeze > requirements.txt