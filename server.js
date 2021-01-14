var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var port = process.env.PORT || 3000;

var clock = require('./clock')
clock.setSocket(io)

// websocket server
io.on('connection', function(socket){
  console.log('A new ws client,' + socket.request.headers['user-agent'])
  console.log('Total sockect: ' + socket.client.conn.server.clientsCount)

  clock.getAlarm() && io.emit('alarmchange', clock.getAlarm())

  socket.on('setalarm', function (data) {
    io.emit('alarmchange', data)
    clock.setAlarm(data)
  })
})

app.use(express.json())

app.post('/heartrate', function (req, res) {
  console.log(req.body)
  clock.update(req.body)
  io.emit('heartrate', JSON.stringify(req.body))
  res.set("Connection", "close");
  res.end(`data saved${JSON.stringify(req.body)}`);
})

app.post('/startworkout', function (req, res) {
  console.log('Record started!')
  clock.start()
  res.set("Connection", "close");
  res.end('Record started!');
})

app.post('/stopworkout', function (req, res) {
  console.log('Record stopped!')
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



