FROM python

WORKDIR /app

RUN pip install --upgrade pip
COPY ./env/requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD python /app/src/manage.py runserver
