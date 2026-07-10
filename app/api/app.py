from flask import Flask, jsonify
import boto3
import os
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from flask import Response
import time

app = Flask(__name__)

sqs = boto3.client("sqs", region_name=os.environ.get("AWS_REGION"))
QUEUE_URL = os.environ.get("QUEUE_URL")

# Define metrics
REQUEST_COUNT = Counter(
    'api_requests_total',
    'Total API requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'api_request_duration_seconds',
    'API request latency',
    ['endpoint']
)

JOB_SENT_COUNT = Counter(
    'api_jobs_sent_total',
    'Total jobs sent to SQS'
)

JOB_ERROR_COUNT = Counter(
    'api_job_errors_total',
    'Total failed SQS job sends'
)

@app.before_request
def start_timer():
    from flask import g
    g.start = time.time()

@app.after_request
def record_metrics(response):
    from flask import g, request
    latency = time.time() - g.start
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(endpoint=request.path).observe(latency)
    return response

@app.route("/api/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/api/job")
def job():
    try:
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody="New job created"
        )
        JOB_SENT_COUNT.inc()
        return jsonify({"message": "Job sent to queue"})
    except Exception as e:
        JOB_ERROR_COUNT.inc()
        return jsonify({"error": str(e)}), 500

@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)