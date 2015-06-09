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

echo "Creating Stack..."

echo "This may take several minutes..."

stackstatus=$(aws cloudformation list-stacks | grep -A 3 "Infra-base" | grep "CREATE_COMPLETE" | cut -d '"' -f 4)

while [ $stackstatus != "CREATE_COMPLETE" ]; do

if [ $stackstatus == "CREATE_COMPLETE" ]; then	

instanceid=$(aws ec2 describe-instances | grep -B 100 -A 8 "WebServer-WordPress" | grep "InstanceId" | cut -d '"' -f 4)

asg=$(aws autoscaling describe-auto-scaling-groups --region sa-east-1 | grep "AutoScalingGroupName" | grep Infra-base | cut -d '"' -f 4)

aws autoscaling attach-instances --instance-ids $instanceid --auto-scaling-group-name $asg --region sa-east-1

fi

done

echo "Stack COMPLETE"
