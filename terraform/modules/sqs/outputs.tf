output "queue_url" {
  value = aws_sqs_queue.job_queue.url
}

output "queue_arn" {
  value = aws_sqs_queue.job_queue.arn
}