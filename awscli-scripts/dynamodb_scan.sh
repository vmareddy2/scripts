
//example using filterexpression
aws dynamodb scan --table-name TEST_TABLE \
--filter-expression "Id = :value AND Type =:value2" \
--expression-attribute-values '{":value":{"S":"mv"},":value2":{"S":"vm"}}'  \
--max-items 10