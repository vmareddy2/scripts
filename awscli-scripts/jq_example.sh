aws datapipeline list-pipelines --profile SQA --region us-east-1 | ~/jq '.[]' | ~/jq '.[] | select(.name | contains("BDP"))' | grep id | awk -F \" '{ print $4 }'