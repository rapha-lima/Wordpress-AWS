#/bin/bash

instance-id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
asg=$(aws autoscaling describe-auto-scaling-groups | grep "AutoScalingGroupName" | grep Infra-base | cut -d '"' -f 4)
aws autoscaling attach-instances --instance-ids $instance-id --auto-scaling-group-name $asg
