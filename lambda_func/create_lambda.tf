provider "aws" {
	region="us-east-2"
	access_key="<access_key>"
	secret_key="<secret_key>"
}

#Zip the function to deploy
data "archive_file" "lambda_zip" {
	type="zip"
	source_file="${path.module}/lambda_function/function.py"
	output_path="${path.module}/lambda_function/function.zip"
}

##S3 Bucket
resource "aws_s3_bucket" "lambda-terraform" {
	bucket="deploymentbucket001"
	acl="private"
	tags= {
		Name="lambda-terraform-bucket-1"
	}
	
}

#Upload zip file to s3 bucket
resource "aws_s3_bucket_object" "object" {
	bucket=aws_s3_bucket.lambda-terraform.id
	key="function.zip"
	source="${path.module}/lambda_function/function.zip"
}

resource "aws_lambda_function" "lambda-function"{
	function_name="function"
	s3_bucket="lambda-terraform"
	s3_key="function.zip"
	role=aws_iam_role.lambda_role.arn
	handler="lambda.handler"
	runtime="python3.6"
}

#AWS IAM Role
resource "aws_iam_role" "lambda_role" {
	name="LambdaRole"
	assume_role_policy=<<EOF
{
	"Version": "2012-10-17",
	"Statement":[
	{
		"Action":"sts:AssumeRole",
		"Effect":"Allow",
		"Principal": {
			"Service":"lambda.amazonaws.com"
		}
	}
	]
}
EOF
}

#AWS IAM RoleSQS Policy

resource "aws_iam_role_policy" "lambda_role_sqs_policy" {
	name="AllowSQSPermissions"
	role=aws_iam_role.lambda_role.id
	policy = <<EOF
{
		"Version": "2012-10-17",
		"Statement" : [
		{
			"Action": [
				"sqs:ChangeMessageVisibility",
				"sqs:DeleteMessage",
				"sqs:GetQueueAttributes",
				"sqs:ReceiveMessage"
			],
			"Effect": "Allow",
			"Resource": "*"
		}
		]
}
EOF
}

#AWS IAM Logs Policy

resource "aws_iam_role_policy" "lambda_role_logs_policy" {
	name="LambdaRolePolicy"
	role="aws_iam_role.lambda_role.id"
	policy = <<EOF
{	
	"Version":"2012-10-17",
	"Statement":[
	{
		"Action": [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:PutLogEvents"
		],
		"Effect":"Allow",
		"Resource":"*"
	}
	]
}
EOF
}

##Data of SQS
data "aws_sqs_queue" "terraform_queue"{
	name="terraform-sqs-queue.fifo"
}

##Event Source mapping
resource "aws_lambda_event_source_mapping" "function" {
	event_source_arn=data.aws_sqs_queue.terraform_queue.arn
	function_name=aws_lambda_function.lambda-function.arn
	
}


