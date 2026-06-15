from flask import Flask, jsonify
import boto3
import os

app = Flask(__name__)

sqs = boto3.client("sqs", region_name=os.environ.get("AWS_REGION"))
QUEUE_URL = os.environ.get("QUEUE_URL")

@app.route("/api/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/api/job")
def job():
    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody="New job created"
    )
    return jsonify({"message": "Job sent to queue"})
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
