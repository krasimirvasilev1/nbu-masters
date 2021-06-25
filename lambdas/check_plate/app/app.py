import json
import base64
import boto3
import datetime
from botocore.exceptions import ClientError
import subprocess


def get_utc_timestamp():
    dt = datetime.datetime.now(datetime.timezone.utc)
    utc_time = dt.replace(tzinfo=datetime.timezone.utc)
    utc_timestamp = utc_time.timestamp()

    return str(utc_timestamp).split(".")[0]


def check_client_record(plates, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb',
                                  aws_access_key_id="test",
                                  aws_secret_access_key="test",
                                  region_name="eu-central-1",
                                  endpoint_url="http://192.168.1.8:8000")  # change needed to put the local IP of the host where dynamo lives (in case of local run)

    table = dynamodb.Table('Clients')

    for plate in plates:
        response = table.get_item(Key={'Plate': plate})
        if 'Item' in response:
            return plate, "Plate - {} EXISTS in the access control system".format(plate), 200
    if not plates:
        return "None", "OpenALPR didn't manage to recognize any plates on the given image", 400

    return plates[0], "Plate - {} DOESN'T EXIST in the access control system".format(plates[0]), 400


def get_plates(img_path):
    try:
        result = subprocess.run(['/srv/openalpr/src/build/alpr', '-c eu', '-j', img_path],
                                stdout=subprocess.PIPE)  # change needed for other country codes
    except subprocess.CalledProcessError as e:
        print(e.output)
    else:
        result_json = json.loads(result.stdout)
        plates = []
        print(result_json)
        if not result_json['results']:
            return plates
        for i in result_json['results'][0]['candidates']:
            plates.append(i['plate'])
        return plates


def decode_img(encoded_img):
    img_name = get_utc_timestamp() + ".jpg"
    img_path = "./tmp_images/" + img_name
    f = open(img_path, "wb")
    f.write(base64.b64decode(encoded_img))
    f.close()
    return img_path


def handler(event, context):
    plates = get_plates(decode_img(event['image']))
    plate, message, status = check_client_record(plates)
    response = {
        'timestamp': get_utc_timestamp(),
        'plate': plate,
        'message': message,
        'status': status
    }
    return json.dumps(response)
