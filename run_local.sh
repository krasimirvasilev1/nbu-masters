#!/bin/bash

cd dynamodb_local && mkdir -p ./docker/dynamodb && docker-compose up -d
cd ../utils && bash dynamo_local_setup.sh
cd ../lambdas/check_plate && docker build -t localfunction:latest . 
docker run -d -p 9000:8080 localfunction:latest

sleep 10 
cd ../../utils/images
(echo -n '{"image": "'; base64 P00399.jpeg; echo '"}') | curl -sH "Content-Type: application/json" -d @- "http://172.18.240.1:9000/2015-03-31/functions/function/invocations"
