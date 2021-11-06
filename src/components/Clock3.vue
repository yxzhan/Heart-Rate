<template>
<div class="clock3">
  <figure class="analog-clock">
    <figcaption class="analog-clock__face">
      <span v-for="n in 60"
        :key="n"
        class="analog-clock__notch"
        :class="{ '-long': !(n % 5) }"
        :style="{ transform: `rotate(${n * 6}deg)` }">
        <span class="panel-digit" :style="{ transform: `rotate(${-n * 6}deg)` }" v-if="digit && !(n % 5)">{{n / 5}}</span>
      </span>
    </figcaption>

    <span class="analog-clock__hand -seconds" :style="seconds"></span>
    <span class="analog-clock__hand -minutes" :style="minutes"></span>
    <span class="analog-clock__hand -hours" :style="hours"></span>
    <span v-show="alarmenable" class="analog-clock__hand -alarm" :style="alarm"></span>

  </figure>
</div>
</template>

<script>

export default {
  name: 'Clock3',
  props: { 
    time: Number, 
    alarmtime: String,
    alarmenable: Boolean,
    digit:{
      default: false,
      type: Boolean
    } 
  },
  data() {
    return {
      minute: 0, 
      tick: 0, 
      rotation: { hours: 0, minutes: 0, seconds: 0, alarm: 0 }
    }
  },
  computed: {
    alarm() {
      return { transform: `translate3d(-50%, 0, 0) rotate(${this.rotation.alarm}deg)` }
    },
    hours() {
      return { transform: `translate3d(-50%, 0, 0) rotate(${this.rotation.hours}deg)` }
    },
    minutes() {
      return { transform: `translate3d(-50%, 0, 0) rotate(${this.rotation.minutes}deg)` }
    },
    seconds() {
      return { transform: `translate3d(-50%, 0, 0) rotate(${this.rotation.seconds}deg)` }
    },
  },
  watch: {
    tick() {
      this.rotation.seconds += 6
      this.rotation.minutes += 0.1
    },
    minute(to, from) {
      if (from === to) return;
      this.rotation.hours += 0.5
      if (this.rotation.hours % 360 == this.rotation.alarm % 360) {
        this.$emit('alarm')
      }
    },
    alarmtime () {
      this.setAlarm()
    },
    time(to, from) {
      if (from == 0) {
        this.initTime()
        return
      }
      let date = new Date(to)
      this.tick = date.getSeconds()
      this.minute = date.getMinutes()
    }
  },
  mounted() {
    this.setAlarm()
  },
  methods: {
    setAlarm () {
      if (!this.alarmtime) return
      let [h, m] = this.alarmtime.split(':')
      this.rotation.alarm = (h * 30) + (m * 0.5) + 0.5
    },
    initTime () {
      let date = new Date(this.time)
      let [h, m, s] = [date.getHours(), date.getMinutes(), date.getSeconds()]
      this.rotation = {
        alarm: this.rotation.alarm,
        hours: (h * 30) + (m * 0.5),
        minutes: (m * 6) + (s * 0.1),
        seconds: s * 6
      }
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.clock3 {
  // width: ;
  text-align: center;
}
.analog-clock {
  display: inline-block;
  width: 60vw;
  height: 60vw;
  // width: 240px;
  // height: 240px;
  position: relative;
  border-radius: 100%;
  background-color: white;
  // margin: 0;
  // transform: translate3d(-1.5rem, -50%, 0);
  filter: drop-shadow(0 0.125rem 0.5rem rgba(black, 0.1));

  &::after {
    top: 50%;
    left: 50%;
    content: '';
    width: 2.5%;
    height: 2.5%;
    position: absolute;
    border-radius: 100%;
    background-color: #edbec5;
    transform: translate3d(-50%, -50%, 0);
  }

  &__face {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
  }

  &__notch {
    transform-origin: 50% 100%;
    position: absolute;
    width: 1px;
    height: 49%;
    bottom: 50%;
    left: 50%;

    &::after {
      content: '';
      width: 100%;
      height: 2.5%;
      position: absolute;
      top: 0;
      left: 0;
      background-color: #b6c3c9;
    }

    &.-long::after {
      width: 2px;
      height: 7.5%;
    }
  }
  .panel-digit {
    position: absolute;
    text-align: center;
    color: #ccc;
    font-size: 3vw;
    left: -1vw;
    
    color: rgb(50, 50, 50);
    // background: yellow;
    // width: 6vw;
    top: 3vw;
  }

  &__hand {
    transform-origin: 50% 100%;
    background-color: #7392a0;
    position: absolute;
    width: 2px;
    height: 40%;
    bottom: 50%;
    left: 50%;
    border-radius: 2px;
    transition: transform 1s linear;

    &::after {
      content: '';
      position: absolute;
      top: 100%;
      left: 0;
      width: 100%;
      height: 10%;
      background-color: inherit;
      backface-visibility: hidden;
    }

    &.-hours {
      height: calc(100% / 3);
      width: 3px;
      border-radius: 3px;
      // transition: transform 100ms linear;
    }
    
    &.-alarm {
      height: 30%;
      width: 2px;
      border-radius: 3px;
      background-color: #f7e78f;

      // transition: transform 100ms linear;
    }

    &.-seconds {
      width: 1px;
      height: 45%;
      border-radius: 0;
      background-color: #edbec5;
      transition: transform 100ms cubic-bezier(.6, .05, 0, 1.6);
      
      // transition: transform 1000ms linear;

      &::after {
        height: 12.5%;
      }
    }
  }
}
</style>
