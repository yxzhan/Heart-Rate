var fs = require('fs')
var moment = require('moment')


var data = []
var started =  false
var heartBeat = 60
var heartTime = null
var timerObj = null
var io = null
var alarm = ''

function countDownHandler (second = 1) {
  heartTime.setSeconds(heartTime.getSeconds() + second)
  timerObj = setTimeout(countDownHandler, 60 / heartBeat * 1000)
  io && io.emit('hearttime', heartTime.getTime())
}

module.exports = {
  update(d) {
    heartBeat = d.val
    data.push(d)
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
