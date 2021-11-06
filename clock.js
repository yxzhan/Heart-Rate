var fs = require('fs')
var mqtt = require('mqtt')

// var mqttUrl = 'mqtt://34.90.188.150'
var mqttUrl = 'mqtt://broker.mqttdashboard.com'

// Global variables
var data = []
var started =  false
var heartBeat = 60
var heartTime = null
var timerObj = null
var io = null
var alarm = '00:00'

// mqtt client
var client  = mqtt.connect(mqttUrl, {
  clientId: 'server_' + Math.random().toString(36).substring(7)
})

var handler = {
  'heartclock/alarm': function (data) {
    alarm = data
  },
  'heartclock/newclient': function (data) {
    client.publish('heartclock/alarm', alarm)
  }
}

client.on('connect', function () {
  console.log('mqtt connected')
  // client.subscribe('heartclock/alarm')
  client.subscribe('heartclock/newclient')
})

client.on('disconnect', function () {
  console.log('mqtt lost connection')
})

client.on('message', function (topic, message) {
  // message is Buffer
  console.log(`Received message ${message} from topic ${topic}`)
  handler[topic](message.toString())
  // client.end()
})

function countDownHandler (second = 1) {
  heartTime.setSeconds(heartTime.getSeconds() + second)
  timerObj = setTimeout(countDownHandler, 60 / heartBeat * 1000)
  client.publish('heartclock/time', heartTime.getTime().toString())
}

// mehtods for http server
module.exports = {
  update(d) {
    console.log(d)
    heartBeat = d.val
    data.push(d)
    client.publish('heartclock/rate', JSON.stringify(d))
  },
  start () {
    if (started) return
    console.log('Clock started!')

    // data = []
    started = true
    if (heartTime == null) {
      heartTime = new Date()
    }
    countDownHandler(0)
  },
  stop () {
    console.log('Clock stopped!')
    started = false
    if (timerObj != null) {
      clearTimeout(timerObj)
    }
    client.publish('heartclock/stop', '')
  },
  getAlarm () {
    return alarm
  },
  setAlarm (val) {
    alarm = val
  },
  setSocket (ioObj) {
    io = ioObj
  },
  reset() {
    heartTime = new Date()
    data = []
  }
}
