var fs = require('fs')
var moment = require('moment')


module.exports = {
  data: [],
  maxDataPoint: 36,



  writeToFile(data) {
    fs.appendFile('data.json', JSON.stringify(data) + ',\n', err => {
      if (err) throw err
    })
  }
}