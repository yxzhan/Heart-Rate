var mqtt = require('mqtt')
var client  = mqtt.connect('mqtt://localhost')
 
client.on('connect', function () {
  client.subscribe('heart/timeupdate', function (err) {
    if (err) { console.log(err)}

  })
  client.subscribe('heartclock/rate')
  client.subscribe('heartclock/time')
  client.subscribe('heartclock/alarm')
})
 
client.on('message', function (topic, message) {
  // message is Buffer
  console.log(message.toString())
  // client.end()
})