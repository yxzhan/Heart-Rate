// var moment = require('moment')
var fs = require('fs')
var mqtt = require('mqtt')

// Global variables
var data = []
var started =  false
var heartBeat = 60
var heartTime = null
var timerObj = null
var io = null
var alarm = '00:00'

// mqtt client
var client  = mqtt.connect('mqtt://localhost')

var handler = {
  'heartclock/alarm': function (data) {
    alarm = data
  },
  'heartclock/newclient': function (data) {
    client.publish('heartclock/alarm', alarm)
  }
}

client.on('connect', function () { 
  client.subscribe('heartclock/alarm')
  client.subscribe('heartclock/newclient')
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
    heartBeat = d.val
    data.push(d)
    client.publish('heartclock/rate', JSON.stringify(d))
  },
  start () {
    if (started) return
    data = []
    started = true
    heartTime = new Date()
    countDownHandler(0)
  },
  stop () {
    started = false
    if (timerObj != null) {
      clearTimeout(timerObj)
    }
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
    data = []
  }
}
