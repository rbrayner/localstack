
.PHONY: help

aws-local-path=~/.local/bin

help:
		@echo "Makefile arguments:"
		@echo ""
		@echo "Makefile commands:"
		@echo "help"
		@echo "install-docker"
		@echo "deploy-localstack"
		@echo "install-aws-local-cli"
		@echo "install-golang"
		@echo "lambda-create"
		@echo "lambda-update"
		@echo "lambda-delete"
		@echo "lambda-list-functions"
		@echo "lambda-invoke"
		@echo "s3-create-bucket"
		@echo "s3-list-buckets"
		@echo "s3-copy-file-to-bucket"
		@echo "s3-list-bucket-content"
		@echo "s3-delete-bucket-file"
		@echo "s3-remove-bucket"
		@echo "install-all"
		@echo "deploy-all"
		@echo "destroy"


.DEFAULT_GOAL := help

install-docker:
		@echo "Installing docker"
		@sudo apt-get install ansible -y
		@sudo ansible-playbook --tags "install" ansible/docker.yml

deploy-localstack:
		@echo "Installing LocalStack"
		@sudo docker rm -f localstack-20201125 | true
		@sudo docker-compose up -d
		@sudo docker logs localstack-20201125
		@echo "Waiting to initialize (60 seconds)..."
		@sleep 60

install-golang:
		@echo "Installing Go"
		@sudo apt install golang-go -y

install-aws-local-cli:
		@echo "Installing awslocal"
		@sudo apt-get install python3 python3-pip -y
		@pip3 install awscli
		@pip3 install awscli-local

lambda-create:
		@echo "Creating a lambda function example"
		@sudo apt-get install zip -y
		@go get github.com/aws/aws-lambda-go/lambda
		@go build -o task
		@zip task.zip task
		@${aws-local-path}/awslocal lambda create-function --function-name=task --runtime="go1.x" --role=fakerole --handler=task --zip-file fileb://task.zip

lambda-update:
		@${aws-local-path}/awslocal lambda update-function-code --function-name=task --zip-file fileb://task.zip

lambda-delete:
		@${aws-local-path}/awslocal lambda delete-function --function-name task

lambda-list-functions:
		@${aws-local-path}/awslocal lambda list-functions

lambda-invoke:
		@echo "Invoking function"
		@sudo docker pull lambci/lambda:go1.x
		@${aws-local-path}/awslocal lambda invoke --function-name task --payload='{"Name": "world"}' --region=us-east-1 myout.log
		@cat myout.log

s3-create-bucket:
		@echo "Creating a bucket example"
		@${aws-local-path}/awslocal s3 mb s3://mybucket

s3-list-buckets:
		@echo "Listing the buckets"
		@${aws-local-path}/awslocal s3 ls

s3-copy-file-to-bucket:
		@echo "Copy a file to a bucket"
		@${aws-local-path}/awslocal s3 cp s3-test-file.txt s3://mybucket

s3-list-bucket-content:
		@echo "Listing the contents of a bucket"
		@${aws-local-path}/awslocal s3 ls s3://mybucket

s3-delete-bucket-file:
		@echo "Deleting a file of a bucket"
		@${aws-local-path}/awslocal s3 rm s3://mybucket/s3-test-file.txt

s3-remove-bucket:
		@echo "Deleting a bucket"
		@${aws-local-path}/awslocal s3 rb s3://mybucket

install-all: install-docker deploy-localstack install-golang install-aws-local-cli
deploy-all: lambda-create lambda-list-functions lambda-invoke s3-create-bucket s3-list-buckets s3-copy-file-to-bucket s3-list-bucket-content
destroy: s3-remove-bucket lambda-delete

