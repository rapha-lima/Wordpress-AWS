#!/bin/bash

read -p "Insert Access Key: " ACCESS_KEY
read -p "Insert Secret Key: " SECRET_KEY

ACCESS_KEY="$ACCESS_KEY"
SECRET_KEY="$SECRET_KEY"

export AWS_ACCESS_KEY_ID=$ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$SECRET_KEY

if ! type vagrant >> /dev/null ; then
  yum install https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.rpm -y
fi

vagrant plugin install vagrant-aws
vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

sudo yum install wget unzip -y

if ! type aws >> /dev/null ; then
  echo "There is no AWS Cli packaged installed. Let's install it."
  wget --quiet https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -O /tmp/awscli-bundle.zip && unzip -qo /tmp/awscli-bundle.zip -d /tmp/ && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
fi

aws ec2 create-key-pair --key-name master --region sa-east-1 --query 'KeyMaterial' --output text > master.pem

chmod 400 master.pem

export VPCID=$(aws ec2 create-vpc --region sa-east-1 --cidr-block 10.0.0.0/16 | grep "VpcId" | cut -d '"' -f 4)

export SubnetId=$(aws ec2 create-subnet --vpc-id $VPCID --cidr-block 10.0.0.0/24 | grep "SubnetId" | cut -d '"' -f 4)

export SG=$(aws ec2 create-security-group --group-name Raphinha-teste --description "Test Security Group" --vpc-id $VPCID | grep "GroupId" | cut -d '"' -f 4)

aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 22 --cidr 0.0.0.0/0

export IGW=$(aws ec2 create-internet-gateway | grep "InternetGatewayId" | cut -d '"' -f 4)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPCID

vagrant up
