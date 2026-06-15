FROM public.ecr.aws/docker/library/python:3.11-slim

WORKDIR /app

COPY app/worker/worker-requirement.txt .
RUN pip install --no-cache-dir -r worker-requirement.txt

COPY app/worker/worker.py .

EXPOSE 5000

CMD ["python", "worker.py"]



