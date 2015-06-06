#!/bin/bash

read -p "Insert Access Key: " AWS_ACCESS_KEY
read -p "Insert Secret Key: " AWS_SECRET_KEY

export AWS_ACCESS_KEY
export AWS_SECRET_KEY

if ! type vagrant >> /dev/null ; then
  yum install https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.rpm -y
fi

vagrant plugin install vagrant-aws
vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

yum install wget unzip -y

if ! type aws >> /dev/null ; then
  echo "There is no AWS Cli packaged installed. Let's install it."
  wget --quiet https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -O /tmp/awscli-bundle.zip && unzip -qo /tmp/awscli-bundle.zip -d /tmp/ && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
fi

aws ec2 create-key-pair --key-name master --region sa-east-1 --query 'KeyMaterial' --output text > master.pem

chmod 400 master.pem

vagrant up
