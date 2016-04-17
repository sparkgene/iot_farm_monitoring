var awsIot = require('aws-iot-device-sdk');
var fs = require('fs');

var version_file = "version"

if (!fs.statSync(version_file)) {
  console.log("no version file");
  process.exit();
}

var version = fs.readFileSync(version_file);

var thingShadows = awsIot.thingShadow({
  keyPath: '/opt/pi_farm/certs/private.pem',
  certPath: '/opt/pi_farm/certs/cert.pem',
  caPath: '/opt/pi_farm/certs/rootca.crt',
  clientId: "pi_001",
  region: 'ap-northeast-1'
});

var clientTokenGet, clientTokenUpdate;

thingShadows.on('connect', function() {
    thingShadows.register( 'pi_farm2' );
    setTimeout( function() {
       clientTokenGet = thingShadows.get('version');
    }, 2000 );
});

thingShadows.on('status', function(thingName, stat, clientToken, stateObject) {
    console.log('status received '+stat+' on '+thingName+': '+
                 JSON.stringify(stateObject));
});

thingShadows.on('delta', function(thingName, stateObject) {
    // check version
    var version = stateObject.state.version;
    console.log('received delta: ' + JSON.stringify(stateObject));
    clientTokenUpdate = thingShadows.update('pi/farm2', {"state":{"reported": {"version": version}}});
});

thingShadows.on('timeout', function(thingName, clientToken) {
     console.log('received timeout '+' on '+operation+': '+
                 clientToken);
});
