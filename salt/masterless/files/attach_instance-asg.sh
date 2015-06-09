#/bin/bash

instanceid=$(curl http://169.254.169.254/latest/meta-data/instance-id)
asg=$(aws autoscaling describe-auto-scaling-groups --region sa-east-1 | grep "AutoScalingGroupName" | grep Infra-base | cut -d '"' -f 4)
aws autoscaling attach-instances --instance-ids $instanceid --auto-scaling-group-name $asg --region sa-east-1
