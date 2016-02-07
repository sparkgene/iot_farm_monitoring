var awsIot = require('aws-iot-device-sdk');
var sys = require('sys')
var exec = require('child_process').exec;

// Define paramerters to publish a message
var device = awsIot.device({
    keyPath: './certs/private.pem',
    certPath: './certs/cert.pem',
    caPath: './certs/rootca.crt',
    clientId: 'pi_farm2',
    region: 'ap-northeast-1'
});

// Connect to Message Broker
device.on('connect', function() {
    console.log('Connected to Message Broker.');

    var record = {
        "message": "hello world!"
    };
    // Serialize record to JSON format and publish a message
    var message = JSON.stringify(record);
    device.publish('pi_farm2/metrics', message, {}, function(){
      console.log("Publish: " + message);
      process.exit();
    });
});
