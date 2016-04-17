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
git clone https://github.com/sparkgene/iot_farm_monitoring.git /opt/pi_farm/release/first

mkdir -p /opt/pi_farm/node_modules
ln -s /opt/pi_farm/node_modules /opt/pi_farm/release/first/node_modules
ln -s /opt/pi_farm/release/first /opt/pi_farm/current

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
touch /opt/pi_farm/certs/rootca.pem # set root CA certificate
```

### environment variables file
```
cp /opt/pi_farm/current/environment_variables.org /opt/pi_farm/current/environment_variables
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
