var express = require('express');
var app = express();
var http = require('http').Server(app);
var port = process.env.PORT || 3000;
var fs = require('fs');
var os = require('os');
var moment = require('moment')
var serveIndex = require('serve-index');

var clock = require('./clock')

var data = []
var currentFileName = ''

app.use(express.json())

app.use('/', express.static('dist'))
app.use('/data', express.static('data'))
app.use('/data',serveIndex(__dirname + '/data'))

app.post('/heartrate', function (req, res) {
  // console.log(req.body)
  req.body['timestamp'] = Math.floor(parseFloat(req.body['timestamp'])*1000)
  clock.update(req.body)
  res.set("Connection", "close");
  res.end(`data saved${JSON.stringify(req.body)}`);
  try {
    fs.appendFile(currentFileName, JSON.stringify(req.body) + os.EOL, function (err) {
      if (err) console.log(err)
      // console.log('Record Updated!');
    });
  } catch (e){
    console.log(e)
  }
})

app.post('/startworkout', function (req, res) {
  clock.start()
  res.set("Connection", "close");
  res.end('Record started!');
  currentFileName = './data/' + moment().format('YY-MM-DD-HHmmss') + '.txt'
  fs.appendFile(currentFileName, '', function (err) {
    if (err) throw err;
    console.log(`file ${currentFileName} created!`);
  });
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



