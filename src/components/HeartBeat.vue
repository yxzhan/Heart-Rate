<template>

  <div class="heart-beat">

    <div class="info-block" v-show="showInfo">
      <div>Heart Rate <b>{{heartBeat}}</b> BPM</div>
      <div class="digit-clock"><b>{{now}}</b></div>
      <div class="digit-clock"><b>{{heartTimeString}}</b></div>
    </div>

    <div class="clock-block">
      <Clock3 :time="heartTimeNum"
              :alarmenable="alarmEnable"
              :digit="digit"
              :alarmtime="alarmtime" @alarm="playAlarm"/>
      <!-- <div class="title">Heart Rate Time</div> -->

    </div>

    <div class="home-settings-btn">
      <button  id="show-modal" @click="showModal = true">Settings</button>
    </div>
    <Modal v-if="showModal">
      <h2 slot="header">Settings</h2>
      <div slot="body">
        <div class="setting-btns">
          <div class="radio">
            <span>Alarm Clock</span>
            <input type="radio" id="alarm-on" v-bind:value="true" v-model="alarmEnable">
            <label for="alarm-on">On</label>
            <input type="radio" id="alarm-off" v-bind:value="false" v-model="alarmEnable">
            <label for="alarm-off">Off</label>
          </div>
          <VueClockPicker 
              v-show="alarmEnable"
              v-model="alarmtime"
              :placeholder="'Set AlarmClock'" 
              v-on:timeset="setAlarm" />
          
          <div class="radio">
            <span>Sound</span>
            <input type="radio" id="sound-on" v-bind:value="false" v-model="muted">
            <label for="sound-on">On</label>
            <input type="radio" id="sound-off" v-bind:value="true" v-model="muted">
            <label for="sound-off">Off</label>
          </div>
          <div class="radio">
            <span>Digit on Panel</span>
            <input type="radio" id="digit-on" v-bind:value="true" v-model="digit">
            <label for="digit-on">Show</label>
            <input type="radio" id="digit-off" v-bind:value="false" v-model="digit">
            <label for="digit-off">Hide</label>
          </div>
          <div class="radio">
            <span>Other info</span>
            <input type="radio" id="info-on" v-bind:value="true" v-model="showInfo">
            <label for="info-on">Show</label>
            <input type="radio" id="info-off" v-bind:value="false" v-model="showInfo">
            <label for="info-off">Hide</label>
          </div>
          

          <!-- <input style="width: 200px" v-model="mqtturl" placeholder="mqtt url"> -->
        </div>
          <!-- <button @click="alarmEnable = !alarmEnable">{{alarmEnable ? 'Turn off Alarm' : 'Turn on Alarm'}}</button>
          <button @click="muted = !muted">{{muted ? 'Turn on Sound' : 'Mute'}}</button> -->
          <!-- <button v-if="alarming" @click="stopAlarm">stop alarm</button> -->
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
          :mqtturl="mqtturl"
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
      showInfo: false,
      digit: false,
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
      alarmEnable: false,
      // mqtturl: 'broker.mqttdashboard.com',
      mqtturl: '34.90.188.150',
      // mqtturl: window.location.host.split(':')[0],
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
      // console.log(data)
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
      if (this.muted) return
      this.tickPlayer.currentTime = 0
      this.tickPlayer.play()
    },
    playAlarm() {
      if (!this.alarmEnable) return
      if (!this.muted) {
        this.alarmPlayer.muted = false
        this.tickPlayer.muted = true
      }
      // this.alarmPlayer.playbackRate = 2
      this.alarmPlayer.currentTime = 0
      this.alarmPlayer.play()
      this.alarming = true
    },
    stopAlarm() {
      this.alarmPlayer.pause()
      if (!this.muted) {this.tickPlayer.muted = false}
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
.home-settings-btn {
  position: absolute;
  top: 0;
  right: 0;
}
.setting-btns {
  margin: 20px 0;
}
.setting-btns>div {
  margin: 15pt 0;
}
.setting-btns .radio>input{
  margin-left: 8pt;
}

button {
  border-radius: 2pt;
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
