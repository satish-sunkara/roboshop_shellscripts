#!/bin/bash

AMI_ID="ami-03265a0778a880afb"
SG_ID="sg-06069d2b0bdaf0215"
HOST_ZONEID=Z08239781GWZF21X2KM8L
DOMAIN=saachi.online
INSTANCE_LIST=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "paymenat" "dispatch" "web")

for i in "${INSTANCE_LIST[@]}"; do
    echo "Instance is : $i"
    if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ]; then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDR=$(aws ec2 run-instances --image-id $AMI_ID  --instance-type $INSTANCE_TYPE  --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)

    echo "$i :: $IP_ADDR"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOST_ZONEID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDR'"
            }]
        }
        }]
    }
        '
done
