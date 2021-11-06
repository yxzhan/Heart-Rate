var Paho = require('paho-mqtt')

// var client  = mqtt.connect('mqtt://broker.mqttdashboard.com')
var client = new Paho.Client('mqtt://broker.mqttdashboard.com')


client.connect({onSuccess: () => {
  client.subscribe('heartclock/rate')
  client.subscribe('heartclock/time')
  client.subscribe('heartclock/alarm')
  var message = new Paho.MQTT.Message('hehe')
  message.destinationName = 'heartclock/newclient'
  client.send(message)
}})

client.onMessageArrived = (message) => {
  console.log(`${message.topic}: ${message.payloadString}`)
}
