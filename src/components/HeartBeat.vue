<template>

  <div class="heart-beat">

    <div>Heart Rate <b>{{heartBeat}}</b> BPM</div>

    <div class="clock-block">
      <Clock3 :time="heartTimeNum" :alarmtime="alarmtime" @alarm="playAlarm"/>
      <!-- <div class="title">Heart Rate Time</div> -->
      <div class="digit-clock"><b>{{heartTimeString}}</b></div>
      <div class="digit-clock"><b>{{now}}</b></div>
    </div>

    <div>
      <button id="show-modal" @click="showModal = true">Settings</button>
    </div>
    <Modal v-if="showModal">
      <!-- <h2 slot="header">Settings</h2> -->
      <div slot="body">
        <VueClockPicker 
          v-show="alarmEnable"
          label="Alarm Clock"
          v-model="alarmtime"
          :placeholder="'Set AlarmClock'" 
          v-on:timeset="setAlarm" />
        <div class="setting-btns">
          <button @click="alarmEnable = !alarmEnable">{{alarmEnable ? 'Turn off Alarm' : 'Turn on Alarm'}}</button>
          <button @click="muted = !muted">{{muted ? 'Turn on Sound' : 'Mute'}}</button>
          <!-- <button v-if="alarming" @click="stopAlarm">stop alarm</button> -->
        </div>
      </div>
      <div slot="footer">
        <button class="modal-default-button" @click="showModal = false">Close</button>
      </div>
    </Modal>
    <Modal v-if="alarming">
      <div slot="body">
        <h1 slot="header">Wake up!!!</h1>
        <div class="setting-btns">
          <button @click="stopAlarm">stop alarm</button>
        </div>
      </div>
      <div slot="footer"></div>
    </Modal>

    <Mqtt :alarmtime="alarmtime"
          @heartclockrate="onHeartrate" 
          @heartclocktime="onHearttime" 
          @heartclockalarm="onAlarmChanged" />
    <audio id="tickAudio" >
      <source src="drum.mp3" type="audio/mpeg">
    </audio>
    <audio id="alarmAudio" >
      <source src="test.mp3" type="audio/mpeg">
    </audio>
  </div>
</template>

<script>
// import Chart from './Chart.vue'
import Mqtt from './Mqtt.vue'
import Modal from './Modal.vue'
import Clock3 from './Clock3.vue'
// import AlarmClock from './AlarmClock.vue'
import VueClockPicker from '@pencilpix/vue2-clock-picker'
import '@pencilpix/vue2-clock-picker/dist/vue2-clock-picker.min.css'

import moment from 'moment'

export default {
  name: 'HeartBeat',
  data: function() {
    return {
      showModal:false,
      socket: null,
      alarmtime: '',
      now: '',
      nowNum: 0,
      heartTimeNum: 0,
      heartBeat: 60,
      tickPlayer: null,
      alarmPlayer: null,
      alarming: false,
      audioSrc: '',
      muted: true,
      alarmEnable: true,
    }
  },
  watch: {
    muted (val) {
      this.tickPlayer.muted = val
      this.alarmPlayer.muted = val
    }
  },
  computed: {
    heartTimeString() {
      return this.getTimeString(new Date(this.heartTimeNum))
    }
  },
  mounted: function() {
    this.tickPlayer = document.getElementById("tickAudio")
    this.alarmPlayer = document.getElementById("alarmAudio")
    this.tickPlayer.muted = this.muted
    this.alarmPlayer.muted = this.muted
    this.updateNowTime()
    setInterval(this.updateNowTime, 1000)
  },
  methods: {
    onAlarmChanged(data) {
      console.log(data)
      this.alarmtime = data
    },
    onHearttime(data) {
      this.heartTimeNum = parseInt(data)
      this.playTickSound()
    },
    onHeartrate(data) {
      var data = JSON.parse(data)
      this.heartBeat = parseInt(data.val)
    },
    playTickSound() {
      this.tickPlayer.currentTime = 0
      this.tickPlayer.play()
    },
    playAlarm() {
      if (!this.alarmEnable) return
      this.tickPlayer.muted = true
      this.alarmPlayer.muted = false
      // this.alarmPlayer.playbackRate = 2
      this.alarmPlayer.currentTime = 0
      this.alarmPlayer.play()
      this.alarming = true
    },
    stopAlarm() {
      this.alarmPlayer.pause()
      this.tickPlayer.muted = false
      this.alarming = false
    },
    updateNowTime() {
      let d = new Date()
      this.now = this.getTimeString(d)
      this.nowNum= d.getTime()
    },
    getTimeString(d){
      return moment(d).format('HH:mm:ss')
    },
    setAlarm (timeStr) {
      this.alarmtime = timeStr
    }
  },
  components: {
    // Chart,
    Clock3,
    VueClockPicker,
    Modal,
    Mqtt    

  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.heart-beat {
  /* max-width: 800px; */
  margin: auto;
}
.title {
  font-size: 28px;
}
.clock-block {
  display: inline-block;
  margin: 20px;
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
.setting-btns {
  margin: 20px 0;
}
button {
  display: block;
  padding: 0 1rem;
  margin: auto;
  background: transparent;
  border: 0;
  flex: 1;
  font-size: 16px;
  font-weight: 500;
  line-height: 32px;
  /* display: inline-block; */
  cursor: pointer;
  color: rgb(164, 139, 209);
}
button:hover {
  background-color: #f5f5f5;
}
button:active {
    background-color: #e6e6e6;
}
</style>
