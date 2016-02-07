## Installation

### update package and
```
sudo apt-get update
sudo apt-get install build-essential python-dev

cd /opt/
sudo git clone https://github.com/sparkgene/iot_farm_monitoring.git
cd /opt/iot_farm_monitoring
npm install aws-iot-device-sdk
```

### install Adfruit DHT library
```
git clone https://github.com/adafruit/Adafruit_Python_DHT.git
cd Adafruit_Python_DHT
sudo python setup.py install
cd  /opt/iot_farm_monitoring
```

### SORACOM Air script
```
git clone https://gist.github.com/j3tm0t0/65367f971c3d770557f3 soracom
mv soracom /opt/
mv /opt/soracom/soracomair /etc/init.d/
chmod 755 /etc/init.d/soracomair
```
