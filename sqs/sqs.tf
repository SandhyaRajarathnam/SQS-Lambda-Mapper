
provider "aws" {
	region="us-east-2"
	access_key= "xyz"
	secret_key= "pqrs"
}

//SQS FIFO QUEUE

resource "aws_sqs_queue" "terraform_queue" {
	name= "terraform-sqs-queue.fifo"
	fifo_queue=true
	content_based_deduplication=true
}
