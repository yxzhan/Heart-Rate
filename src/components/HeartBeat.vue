<template>

  <div class="heart-beat">
    <div>Current Heart Rate <b>{{heartBeat}}</b></div>
    <div class="clock">
      <div>Heart Rate Time</div>
      <div class="digit-clock"><b>{{heartTimeString}}</b></div>
      <clock :time="heartTimeString" color="#FFFFFF" bg="#4AB7BD"></clock>
    </div>
    <div class="clock">
      <div>Now</div>
      <div class="digit-clock"><b>{{now}}</b></div>
      <clock></clock>
    </div>
    <ul>
      <li v-for="(item, index) in dataList" :key="index">
            <span>Heart Rate: <b>{{item.val}}</b>bpm</span>
            <span>Record Time: <b>{{item.timestamp}}</b></span>
            <span>Fetch Time: <b>{{item.now}}</b></span>
        </li>
    </ul>
  </div>
</template>

<script>
import moment from 'moment'
import Clock from 'vue-clock2'
import io from'socket.io-client'

const wsUrl = 'ws://192.168.1.153:3000/'

export default {
  name: 'HeartBeat',
  data: function() {
    return {
      socket: null,
      now: '',
      heartTimeString: '',
      heartTime: null,
      heartBeat: 60,
      dataList: [],
    }
  },
  mounted: function() {
    this.startClock()
    this.startWs()
  },
  methods: {
    startWs () {
      this.socket = io(wsUrl)
      this.socket.on('message', this.onMessage)
    },
    onMessage(data) {
      var data = JSON.parse(data)
      // console.log(Date.now() - parseFloat(data.timestamp) * 1000)
      this.heartBeat = parseInt(data.val)
      data.now = this.getTimeString(new Date())
      data.timestamp = this.getTimeString(new Date(parseFloat(data.timestamp) * 1000))
      this.dataList.push(data)
    },
    startClock () {
      this.heartTime = new Date()
      this.heartTimeString = this.getTimeString(this.heartTime)

      setTimeout(this.updateHeartTime, this.getHeartSecond())

      this.now = this.getTimeString(new Date())
      setInterval(() => {
        this.now = this.getTimeString(new Date())
      }, 1000)
    },
    updateHeartTime() {
      this.heartTime.setSeconds(this.heartTime.getSeconds() + 1)
      this.heartTimeString = this.getTimeString(this.heartTime)
      setTimeout(this.updateHeartTime, this.getHeartSecond())
    },
    getHeartSecond() {
      return 60 / this.heartBeat * 1000
    },
    getTimeString(d){
      return moment(d).format('HH:mm:ss')
    }
  },
  components: {
    Clock,
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.heart-beat {
  max-width: 800px;
  margin: auto;
}
.clock {
  display: inline-block;
  margin: 30px 20px;
}
.digit-clock {
  font-size: 36px;
}

ul {
  list-style-type: none;
  padding: 0;
  display: flex;
  flex-direction: column-reverse;
}
ul li{
  flex: 0 0 auto;
}
ul li:nth-child(2n){
  background: #eee;
}

ul li span {
  margin: 0 10px;
  display: inline-block;

}
ul li span b{
  margin: 0 5px;
}
</style>
