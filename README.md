### Serverless Parking Management Cloud-Based System with Microcontroller Endpoints

Providing access management mechanisms by leveraging microcontroller endpoints and Serverless Cloud System and Services.

### Local configuration for lambda and dynamodb instances 

Define and run Docker container instance on which the dynamo-db instance will run. The orchestration is managed by docker-compose.yaml file which specify what image is required. 

```bash
cd dynamodb_local && mkdir -p ./docker/dynamodb && docker-compose up -d
```

Give required permissions. Create database table and populate it with test values. 

```bash
cd ../utils && bash dynamo_local_setup.sh
```

Build and run Lambda. Install needed dependencies, setup build environment and compile environment for lambda function.  Install prerequisites. Wait till the process is finished.

```bash
cd ../lambdas/check_plate && docker build -t localfunction:latest . 
docker run -d -p 9000:8080 localfunction:latest
sleep 10
```

Test cloud serverless functionality. It should return "Success" response to indicated successful execution.

```bash
cd ../../utils/images
(echo -n '{"image": "'; base64 P00399.jpeg; echo '"}') | curl -sH "Content-Type: application/json" -d @- "http://172.18.240.1:9000/2015-03-31/functions/function/invocations"
```

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker Pi
sudo systemctl enable docker.service && sudo systemctl enable containerd.service
```

Pull docker image which contains OpenALPR software for automatic number-plate recognition. The image will be used for an offline check or in other words when there is no internet access.

```bash
docker pull krasimirvasilev1/nbu-alpr
```
