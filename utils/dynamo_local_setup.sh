# fix permissions 
# sudo chown user dynamodb -R
chmod 775 -R ../dynamodb_local/docker/dynamodb

# create table 
aws dynamodb create-table --table-name Clients \
--attribute-definitions \
AttributeName=Plate,AttributeType=S \
--key-schema \
AttributeName=Plate,KeyType=HASH \
--provisioned-throughput \
ReadCapacityUnits=1,WriteCapacityUnits=1 \
--endpoint-url http://localhost:8000

# put items
aws dynamodb put-item --table-name Clients --item '{"Plate": {"S": "H786P0J"}}' --endpoint-url http://localhost:8000
aws dynamodb put-item --table-name Clients --item '{"Plate": {"S": "LIPME126"}}' --endpoint-url http://localhost:8000
aws dynamodb put-item --table-name Clients --item '{"Plate": {"S": "KPC1313"}}' --endpoint-url http://localhost:8000
aws dynamodb put-item --table-name Clients --item '{"Plate": {"S": "HH0L7687"}}' --endpoint-url http://localhost:8000
