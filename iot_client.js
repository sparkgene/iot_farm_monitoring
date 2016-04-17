var awsIot = require('aws-iot-device-sdk');
var sys = require('sys');
var fs = require('fs');
var os = require('os');

var metric_file = "/opt/pi_farm/data/metrics/upload_data.csv"

if (!fs.statSync(metric_file)) {
  console.log("no data file");
  process.exit(1);
}

var metrics = fs.readFileSync(metric_file);

// Define paramerters to publish a message
var device = awsIot.device({
    keyPath: '/opt/pi_farm/certs/private.pem',
    certPath: '/opt/pi_farm/certs/cert.pem',
    caPath: '/opt/pi_farm/certs/rootca.crt',
    clientId: "pi_001",
    region: 'ap-northeast-1'
});

// Connect to Message Broker
device.on('connect', function() {
    console.log('connected');
    var record = {
        "device": os.hostname(),
        "metrics": metrics.toString()
    };
    // Serialize record to JSON format and publish a message
    var message = JSON.stringify(record);
    device.publish('pi_farm2/metrics', message, {}, function(){
      console.log("Publish: " + message);
      setTimeout(function(){
        console.log('close');
        device.end();
      },1000);
    });
});
