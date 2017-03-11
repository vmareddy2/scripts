for i in `cat tablelist.txt`
do
        echo "Table Name is " $i
        aws dynamodb tag-resource --resource-arn arn:aws:dynamodb:$Region:$AccountID:table/$i --tags Key=PLATFORM,Value=Dynamo Key=Name,Value=$i Key=BUSINESS_REGION,Value=NORTHAMERICA  --profile $ENV
done;