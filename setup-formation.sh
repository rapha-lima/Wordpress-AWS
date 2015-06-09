#!/bin/bash

read -p "Insert Access Key: " AWS_ACCESS_KEY
read -p "Insert Secret Key: " AWS_SECRET_KEY

export AWS_ACCESS_KEY=$AWS_ACCESS_KEY
export AWS_SECRET_KEY=$AWS_SECRET_KEY

sudo yum install wget unzip -y

if ! type aws >> /dev/null ; then
  echo "There is no AWS Cli packaged installed. Let's install it."
  sudo wget --quiet https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -O /tmp/awscli-bundle.zip && unzip -qo /tmp/awscli-bundle.zip -d /tmp/ && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
fi

aws ec2 create-key-pair --key-name wordpress --region sa-east-1 --query 'KeyMaterial' --output text > wordpress.pem

chmod 400 wordpress.pem

aws cloudformation create-stack --stack-name Infra-base --template-body file://aws//templates//Infra-Base.json --region sa-east-1 --capabilities CAPABILITY_IAM

