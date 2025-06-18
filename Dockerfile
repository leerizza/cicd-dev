FROM python:3.9-slim

WORKDIR /app

COPY . .

RUN pip install pytest dbt-core

CMD ["pytest"]
