
provider "aws" {
	region="us-east-2"
	access_key= "AKIAX22GPDLA3CVOB7PD"
	secret_key= "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"
}

//SQS FIFO QUEUE

resource "aws_sqs_queue" "terraform_queue" {
	name= "terraform-sqs-queue.fifo"
	fifo_queue=true
	content_based_deduplication=true
}
