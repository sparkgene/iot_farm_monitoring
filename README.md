## Overview
This is a sample project for monitoring farm.
Using Raspberry Pi for the gateway.

Raspberry Pi collect metrics from following sensors.
- DHT11 (Humidity & Temperature sensor)
- GY30/BH1750FVI (Digital Light intensity detection module)
- YL-69 (soil moisture sensors)

## Installation

### update package
```
sudo apt-get update
sudo apt-get install build-essential python-dev
```

### clone source and install node modules
```
sudo su
mkdir -p /opt/pi_farm/release
git clone https://github.com/sparkgene/iot_farm_monitoring.git /opt/pi_farm/release/20160417000000

mkdir -p /opt/pi_farm/node_modules
ln -s /opt/pi_farm/node_modules /opt/pi_farm/release/first/node_modules
ln -s /opt/pi_farm/release/20160417000000 /opt/pi_farm/current

cd /opt/pi_farm/current
npm install npm -g
npm install aws-iot-device-sdk
```

### install Adfruit DHT library
```
cd /opt/pi_farm
git clone https://github.com/adafruit/Adafruit_Python_DHT.git
cd Adafruit_Python_DHT
sudo python setup.py install
```

### SORACOM Air script
```
cd /opt
sudo git clone https://gist.github.com/j3tm0t0/65367f971c3d770557f3 sora
sudo mv /opt/sora/soracomair /etc/init.d/
sudo chmod 755 /etc/init.d/soracomair
```

### AWS IoT certificates
```
mkdir /opt/pi_farm/certs
touch /opt/pi_farm/certs/private.pem # set your private key
touch /opt/pi_farm/certs/cert.pem # set your certificate
wget  https://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem -O /opt/pi_farm/certs/rootca.pem
```

### environment variables file
```
cp /opt/pi_farm/current/environment_variables.org /opt/pi_farm/environment_variables
# edit the variables
```

### setup cron
```
crontab /opt/pi_farm/current/crontab
```

### data directories
```
mkdir -p /opt/pi_farm/data/metrics
mkdir -p /opt/pi_farm/data/photos
```
