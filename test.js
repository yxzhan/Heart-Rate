var clock = require('./clock')

clock.start()

setInterval(function () {
  var data  = {
    "val": Math.floor(100 + Math.random() * 50),
    "timestamp": Date.now()
  }
  clock.update(data)
}, 5000)