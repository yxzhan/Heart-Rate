<template>

  <div class="heart-beat">
    <div>Current Heart Rate <b>{{heartBeat}}</b></div>
    <div class="clock-block">
      <div class="title">Heart Rate Time</div>
      <div class="digit-clock"><b>{{heartTimeString}}</b></div>
      <!-- <clock :time="heartTimeString" color="#FFFFFF" bg="#4AB7BD" size="300px"></clock> -->
      <Clock3 :time="heartTimeNum"/>

    </div>
    <div class="clock-block">
      <div class="title">Now</div>
      <div class="digit-clock"><b>{{now}}</b></div>
      <!-- <clock size="300px"></clock> -->
      <Clock3 :time="nowNum"/>
    </div>
    <AlarmClock :time="heartTimeNum"/>
    <audio id="myAudio" >
      <source :src="audioSrc" type="audio/mpeg">
    </audio>
    <!-- <Chart ref="chartComponent"/> -->
    <!-- <ul>
      <li v-for="(item, index) in dataList" :key="index">
            <span>Heart Rate: <b>{{item.val}}</b>bpm</span>
            <span>Record Time: <b>{{item.timestamp}}</b></span>
            <span>Fetch Time: <b>{{item.now}}</b></span>
        </li>
    </ul> -->
  </div>
</template>

<script>
import Chart from './Chart.vue'
import Clock3 from './Clock3.vue'
import AlarmClock from './AlarmClock.vue'

import moment from 'moment'
import io from'socket.io-client'

export default {
  name: 'HeartBeat',
  data: function() {
    return {
      alarmClocks:[],
      socket: null,
      now: '',
      nowNum: 0,
      heartTimeString: '',
      heartTime: null,
      heartTimeNum: 0,
      heartBeat: 60,
      dataList: [],
      audioPlayer: null,
      audioSrc: ''
    }
  },
  mounted: function() {
    this.audioPlayer = document.getElementById("myAudio")
    // this.audioPlayer.muted = true
    this.startWs()
    this.updateNowTime()
    setInterval(this.updateNowTime, 1000)
  },
  methods: {
    startWs () {
      this.socket = io()
      this.socket.on('message', this.onMessage)
      this.socket.on('history', data => {
        data = JSON.parse(data)
        this.initHeartTime(data)
        this.$refs.chartComponent && this.$refs.chartComponent.initChart(data)
      })
    },
    onMessage(data) {
      var data = JSON.parse(data)
      this.$refs.chartComponent && this.$refs.chartComponent.onRecieveData(data)
      this.heartBeat = parseInt(data.val)
      // data.now = this.getTimeString(new Date())
      // data.timestamp = this.getTimeString(new Date(parseFloat(data.timestamp) * 1000))
      // this.dataList.push(data)
    },
    playBeatSound() {
      this.audioSrc = 'drum.mp3'
      this.audioPlayer.pause();
      this.audioPlayer.currentTime = 0
      this.audioPlayer.play()
    },
    updateHeartTime(second = 1) {
      // this.playBeatSound()
      this.heartTime.setSeconds(this.heartTime.getSeconds() + second)
      this.heartTimeString = this.getTimeString(this.heartTime)
      this.heartTimeNum = this.heartTime.getTime()
      setTimeout(this.updateHeartTime, this.getHeartSecond())
    },
    updateNowTime() {
      let d = new Date()
      this.now = this.getTimeString(d)
      this.nowNum= d.getTime()
    },
    getHeartSecond() {
      return 60 / this.heartBeat * 1000
    },
    getTimeString(d){
      return moment(d).format('HH:mm:ss')
    },
    initHeartTime(data) {
      if (data.length == 0) return
      this.heartBeat = data[data.length - 1].val
      var gap = (data.map(v => v.val).reduce((a, b) => a + b)) / 15
      this.heartTime = new Date((parseFloat(data[0].timestamp) + gap) * 1000)
      this.heartTimeString = this.getTimeString(this.heartTime)
      this.heartTimeNum = this.heartTime.getTime()
      this.updateHeartTime(0)
    }
  },
  components: {
    // Clock,
    Chart,
    Clock3,
    AlarmClock,
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.heart-beat {
  max-width: 800px;
  margin: auto;
}
.title {
  font-size: 28px;
}
.clock-block {
  display: inline-block;
  margin: 30px 20px;
}

.clock-block div {
  margin: 10px 0;
}

.clock-block .clock {
  border: none;
}

.digit-clock {
  font-size: 28px;
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
