
<template>

  <div class="alarm-clock">
    <h2>Alarm panel</h2>
    <button v-on:click="playAudio">Play Alarm</button>
    <button v-on:click="stopAudio">Stop Alarm</button>
    <div class="alarm-clock-list">
        <h3>{{titleText}}</h3>
        <ul>
          <li v-for="(item, index) in alarmList" :key="index">
                <span>{{item}}</span>
                <a href="#" v-on:click="deleteAlarms(index)">Delete</a>
            </li>
        </ul>
    </div>
    <VueClockPicker 
    :placeholder="'+ Add AlarmClock'" 
    v-on:timeset="addAlarm" 
    :input-class="'add-alarm-clock-btn'"/>

    <audio id="alarmAudio" >
      <source :src="audioSrc" type="audio/mpeg">
    </audio>
  </div>
</template>

<script>
import moment from 'moment'
import VueClockPicker from '@pencilpix/vue2-clock-picker'
import '@pencilpix/vue2-clock-picker/dist/vue2-clock-picker.min.css'
const lsKey = 'alarmClocks'

export default {
  name: 'AlarmClock',
  props: { 
    time: Number, 
  },
  data: function() {
    return {
      alarmList: [],
      audioPlayer: null,
      audioSrc: 'test.mp3',
    }
  },
  computed: {
    titleText () {
      return this.alarmList == 0 ? 'No alarms on' : 'Active alarms:' 
    }
  },
  watch: {
    time() {
      // console.log(this.time)
      // this.updateView()
      this.checkTime()
    }
  },
  mounted: function() {
    this.alarmList = JSON.parse(localStorage.getItem(lsKey)) || []
    this.audioPlayer = document.getElementById("alarmAudio")
  },
  methods: {
    addAlarm(timeStr) {
      if (this.alarmList.includes(timeStr)) return
      this.alarmList.push(timeStr)
      localStorage.setItem(lsKey, JSON.stringify(this.alarmList))
      console.log(JSON.stringify(this.alarmList))
    },
    deleteAlarms(index) {
      if (index > -1) {
        this.alarmList.splice(index, 1);
      }
      localStorage.setItem(lsKey, JSON.stringify(this.alarmList))
    },
    checkTime() {
      let d = new Date(this.time)
      let str = moment(d).format('HH:mm:ss')
      if (this.alarmList.map(v => v + ':00').includes(str)){
        this.playAudio()
      } 
    },
    playAudio() {
      this.audioPlayer.play()
    },
    stopAudio() {
      this.audioPlayer.pause()
      this.audioPlayer.currentTime = 0
    }
  },
  components: {
    VueClockPicker,
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
.alarm-clock {
  margin: 20px auto;
  width:200px;
  border: 1px dashed;
  padding: 20px;
}
.add-alarm-clock-btn {
  text-align: center;
  font-size: 16px;
  line-height: 32px;
  cursor: pointer;

}
.add-alarm-clock-btn:hover {
  /* background: #f5f5f5; */
}
.alarm-clock ul {
  list-style-type: none;
  padding: 0;
  display: flex;
  flex-direction: column-reverse;
}
.alarm-clock ul li a{
  text-decoration: none;
  margin-left: 10px;
}

</style>
