
<template>

  <div class="chart">
    <canvas id="myChart" width="400" height="200"></canvas>

  </div>
</template>

<script>
import Chart from 'chart.js'
import moment from 'moment'

import io from'socket.io-client'

export default {
  name: 'Chart',
  data: function() {
    return {
      chartObj: null,
      maxDataPoint: 36,
    }
  },
  mounted: function() {
    
  },
  methods: {
    initChart:function (data){
      data = data.slice(data.length - this.maxDataPoint, length.length)
      this.chartObj = new Chart(document.getElementById('myChart'), {
        type: 'line',
        data: {
          labels: data.map(v => this.formatTime(v.timestamp)),
          datasets: [{
              data: data.map(v => v.val),
              label: (data && data.length != 0) ? this.formatDate(data[data.length - 1].timestamp): '',
              backgroundColor: "#fb6384",
              borderColor: "#fb6384",
              fill: false,
            }
          ]
        },
        options: {
          scales: {
            // yAxes: [{
            //     ticks: {
            //         suggestedMin: 90,
            //         suggestedMax: 120
            //     }
            // }],
            xAxes: [{
              gridLines: {
                display:false
              }
            }],
          },
          tooltips: {
            enabled: true,
            callbacks: {
              label: function(tooltipItem, data) {
                return tooltipItem.value
              }
            }
          }
        }
      })
    },
    onRecieveData:function (data){
      if (!this.chartObj) return
      let d = 
      this.chartObj.data.labels.push(this.formatTime(data.timestamp));
      this.chartObj.data.datasets.forEach((dataset) => {
          dataset.data.push(data.val)
          dataset.label = this.formatDate(data.timestamp)
      })
      if (this.chartObj.data.labels.length >= this.maxDataPoint) {
        this.chartObj.data.labels.shift()
        this.chartObj.data.datasets.forEach((dataset) => {
          dataset.data.shift()
        })
      }
      this.chartObj.update()
    },
    formatTime: function (timestamp) {
      let d = new Date(parseFloat(timestamp) * 1000)
      return moment(d).format('HH:mm:ss')
    },
    formatDate: function (timestamp) {
      let d = new Date(parseFloat(timestamp) * 1000)
      return moment(d).format('YYYY-MM-DD')
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
