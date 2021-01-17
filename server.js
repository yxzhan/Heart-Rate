var express = require('express');
var app = express();
var http = require('http').Server(app);
var port = process.env.PORT || 3000;

var clock = require('./clock')

app.use(express.json())

app.post('/heartrate', function (req, res) {
  console.log(req.body)
  clock.update(req.body)
  res.set("Connection", "close");
  res.end(`data saved${JSON.stringify(req.body)}`);
})

app.post('/startworkout', function (req, res) {
  clock.start()
  res.set("Connection", "close");
  res.end('Record started!');
})

app.post('/stopworkout', function (req, res) {
  clock.stop()
  res.set("Connection", "close");
  res.end('Record stopped!');
})

app.post('/resetclock', function (req, res) {
  console.log('Reset clock')
  clock.reset()
  res.set("Connection", "close");
  res.end('Record stopped!');
})

http.listen(port, function(){
  console.log('listening on port: ' + port);
});



