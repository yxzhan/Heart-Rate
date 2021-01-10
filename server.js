var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var port = process.env.PORT || 3000;

var clock = require('./clock')


// websocket server
io.on('connection', function(socket){
  console.log('A new ws client, total sockect: ' + socket.client.conn.server.clientsCount)
  console.log(socket.request.headers['user-agent'])
  // io.emit('history', JSON.stringify(data))
})

app.use(express.json())

app.post('/heartrate', function (req, res) {
  console.log(req.body)
  clock.data.push(req.body)
  io.emit('message', JSON.stringify(req.body))
  res.set("Connection", "close");
  res.end(`data saved${JSON.stringify(req.body)}`);
})

app.post('/startworkout', function (req, res) {
  console.log('Record started!')
  res.set("Connection", "close");
  res.end('Record started!');
})

app.post('/stopworkout', function (req, res) {
  console.log('Record stopped!')
  res.set("Connection", "close");
  res.end('Record stopped!');
})

app.post('/resetclock', function (req, res) {
  console.log('Reset clock')
  clock.data = []
  res.set("Connection", "close");
  res.end('Record stopped!');
})

http.listen(port, function(){
  console.log('listening on port: ' + port);
});



