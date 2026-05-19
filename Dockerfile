FROM python:3.11-slim

ARG ARTIFACT_FILE

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY ${ARTIFACT_FILE} /tmp/bookshop-app.tar.gz
RUN tar -xzf /tmp/bookshop-app.tar.gz -C /app \
    && rm /tmp/bookshop-app.tar.gz \
    && pip install --no-cache-dir --no-index --find-links /app/wheels -r /app/requirements.txt \
    && rm -rf /app/wheels

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
