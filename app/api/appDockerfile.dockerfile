FROM public.ecr.aws/docker/library/python:3.11-slim

WORKDIR /app

COPY app/api/app-requirement.txt .
RUN pip install --no-cache-dir -r app-requirement.txt

COPY app/api/app.py .

EXPOSE 5000

CMD ["python", "app.py"]



