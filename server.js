
var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http, {
  cors: {
    origin: '*',
  }
});
var port = process.env.PORT || 3000;

// websocket server
io.on('connection', function(socket){
  console.log('A new ws client, total sockect: ' + socket.client.conn.server.clientsCount)
});

app.use(express.json())

app.get('/test', function (req, res) {
  console.log(new Date() + '\nget test')
  res.end('this is a test api')
})

app.post('/heartrate', function (req, res) {
  // console.log(new Date() + '\npost heart rate')
  // console.log(Date.now() - parseFloat(req.body.timestamp) * 1000)
  console.log(req.body)
  io.emit('message', JSON.stringify(req.body))
  res.setHeader('Content-Type', 'application/json');
  res.set("Connection", "close");
  res.end(JSON.stringify(req.body));
})

http.listen(port, function(){
  console.log('listening on port: ' + port);
});

// setInterval(()=>{
//   io.emit('message', JSON.stringify({
//     timestamp: '2020-12-16 15:27:45',
//     val: 78,
//     successSent: 81,
//     totalSent: 114
//   }));
// }, 1000)
