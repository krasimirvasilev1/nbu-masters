### Serverless Parking Management Cloud-Based System with Microcontroller Endpoints

Providing access management mechanisms by leveraging microcontroller endpoints and Serverless Cloud System and Services.

### Local configuration for lambda and dynamodb instances 

1. Define and run Docker container instance on which the dynamo-db instance will run. The orchestration is managed by docker-compose.yaml file which specify what image is required. 

```bash
cd dynamodb_local && mkdir -p ./docker/dynamodb && docker-compose up -d
```

2. Give required permissions. Create database table and populate it with test values. 

```bash
cd ../utils && bash dynamo_local_setup.sh
```

3. Build and run Lambda. Install needed dependencies, setup build environment and compile environment for lambda function.  Install prerequisites. Wait till the process is finished.

```bash
cd ../lambdas/check_plate && docker build -t localfunction:latest . 
docker run -d -p 9000:8080 localfunction:latest
sleep 10
```

4. Test cloud serverless functionality. It should return "Success" response to indicated successful execution.

```bash
cd ../../utils/images
(echo -n '{"image": "'; base64 P00399.jpeg; echo '"}') | curl -sH "Content-Type: application/json" -d @- "http://172.18.240.1:9000/2015-03-31/functions/function/invocations"
```

### Rasberry setup

1. Insert SD card into the Raspberry Pi and install the OS as per [https://www.raspberrypi.org/documentation/installation/installing-images/]()

2. Once the OS is installed, execute the following commands. Wait until all prerequisite packages are installed !

```bash
apt update && apt upgrade && apt install -y jq motion
```

3. Install Docker by following these steps:

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker Pi
sudo systemctl enable docker.service && sudo systemctl enable containerd.service
```

4. Apply the configuration file used by Motion. This can be done with the below command executed from the root directory of the repository. Placeholder should be replaced regarding the IP address of the machine that is running.

```
scp ./raspberry/motion.conf pi@{RASPBERRY_IP}:/etc/motion
```
5. Wire the LEDs and the resistors following this schematic - [https://images.app.goo.gl/yhGTY9iL2KfGztLc7]()

6. Add the `rasp_check.sh` file to `/var/lib/motion` by executing the following command from the root directory of the repository.

```
scp ./raspberry/rasp_check.sh pi@{RASPBERRY_IP}:/var/lib/motion
```

7. Start the motion service

```
sudo systemctl start motion
```

8. Pull docker image which contains OpenALPR software for automatic number-plate recognition. The image will be used for an offline check or in other words when there is no internet access.

```
docker pull krasimirvasilev1/nbu-alpr
```
