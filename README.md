## Overview
This is a sample for monitoring the field.
By measuring Temperature, humidity, illuminance, the moisture, you can know the state of the field.
In addition, regularly shoot the field, and upload images to S3 to the bucket.

![graph screenshot](https://raw.githubusercontent.com/sparkgene/iot_farm_monitoring/master/pi_farm_graph.png)

## Raspberry Pi
![graph screenshot](https://raw.githubusercontent.com/sparkgene/iot_farm_monitoring/master/pi_farm_breadboard.png)

## Installation

### Setup AWS
#### S3
create 2 bucket

* bucket-images
* bucket-videos

#### ACCESS KEY
generate a new access key which have this policy

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "Stmt1461402974000",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::bucket-images",
                "arn:aws:s3:::bucket-images/*",
                "arn:aws:s3:::bucket-videos",
                "arn:aws:s3:::bucket-videos/*"
            ]
        }
    ]
}       
```
#### Lambda
Create a 2 lambda function.

* Runtime
 * Python2.7
* source
 * metric store function
     * https://github.com/sparkgene/iot\_farm\_monitoring/blob/master/lambda_function.py
 * video converter function
      * https://github.com/sparkgene/lambda\_image\_to_video
      * scheduled to execute each hour

#### AWS IoT

|AWS IoT Resource|key|value|
|:--|:--|:-:|
|Thing|name|pi_farm2|
|Policy|name|pi-farm2-policy|
|Rule|name|pi\_farm2_rule|
|Rule|Query|SELECT * FROM 'pi_farm2/metrics'|
|Rule|Action|lambda (`metric store function` created at previous step)

Shadow state

```
{
  "desired": {
    "source_version": 1(set the version of https://github.com/sparkgene/iot\_farm_monitoring/blob/master/version)
  }
}
```

Policy Document

```
{
  "Statement": [
    {
      "Action": "iot:*",
      "Resource": "*",
      "Effect": "Allow"
    }
  ],
  "Version": "2012-10-17"
}
```

### Setup Raspberry Pi
#### update package
```
sudo su
apt-get update
apt-get install build-essential python-dev git
npm install npm -g
```

#### install Adfruit DHT library
```
cd /opt/
git clone https://github.com/adafruit/Adafruit_Python_DHT.git
cd Adafruit_Python_DHT
python setup.py install
```

#### SORACOM Air script
```
cd /opt/
git clone https://gist.github.com/j3tm0t0/65367f971c3d770557f3 sora
mv /opt/sora/soracomair /etc/init.d/
chmod 755 /etc/init.d/soracomair
```

#### setup pi_farm
create directories

```
mkdir /opt/pi_farm
cd /opt/pi_farm
mkdir certs
mkdir -p data/metrics
mkdir -p data/photos
mkdir node_modules
mkdir release
```

clone pi_farm

```
cd /opt/pi_farm/release
git clone https://github.com/sparkgene/iot_farm_monitoring.git 0000
```
install AWS SDK

```
cd 0000
ln -s /opt/pi_farm/node_modules ./node_modules
npm install aws-iot-device-sdk
```
create environment_variables file

```
cp environment_variables.org environment_variables
```

set the variables

```
vi environment_variables

S3_BUCKET=<S3 bucket to upload pictures>
IOT_PRODUCT=pi_farm
IOT_CLIENT_ID=pi2
AWS_ACCESS_KEY=<ACCESS KEY>
AWS_SECRET_KEY=<SECRET KEY>
AWS_REGION=ap-northeast-1
GIT_REPO=https://github.com/sparkgene/iot_farm_monitoring.git
```

register crontab

```
crontab ./crontab
```
