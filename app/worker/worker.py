import boto3
import os
import time

sqs = boto3.client("sqs", region_name=os.environ.get("AWS_REGION"))
QUEUE_URL = os.environ.get("QUEUE_URL")

while True:
    response = sqs.receive_message(
        QueueUrl=QUEUE_URL,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=10
    )

    messages = response.get("Messages", [])

    for message in messages:
        print("Processing:", message["Body"])

        sqs.delete_message(
            QueueUrl=QUEUE_URL,
            ReceiptHandle=message["ReceiptHandle"]
        )

    time.sleep(3)
