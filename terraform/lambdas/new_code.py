import json
import logging
import os
import time
import uuid
from datetime import datetime
import boto3

REGION = os.environ['REGION']
DYNAMODB_TABLE = os.environ['DYNAMODB_TABLE']
FARGATE_CLUSTER = os.environ['FARGATE_CLUSTER']
FARGATE_TASK_DEF_NAME = os.environ['FARGATE_TASK_DEF_NAME']
FARGATE_SUBNET_ID = os.environ['FARGATE_SUBNET_ID']

def handler(event,context):
  client = boto3.client('ecs')
  response = client.run_task(
  cluster='fargatecluster', # name of the cluster
  launchType = 'FARGATE',
  taskDefinition='elsys:latest', # replace with your task definition name and revision
  count = 1,
  platformVersion='LATEST',
  networkConfiguration={
        'awsvpcConfiguration': {
            'subnets': [
                'subnet-2ec3a94a', # replace with your public subnet or a private with NAT
                'subnet-413a9c6e' # Second is optional, but good idea to have two
            ],
            'assignPublicIp': 'DISABLED'
        }
    })
  return str(response)
