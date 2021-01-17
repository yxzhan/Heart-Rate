
<template>

  <div class="Mqtt">
    <!-- <div>{{errorMsg}}</div> -->
  </div>
</template>

<script>

import Paho from 'paho-mqtt'

export default {
  name: 'Mqtt',
  props: { 
    alarmtime: String,
  },
  watch:{
    alarmtime(val) {
      // this.client.publish('heartclock/alarm', val)
      var message = new Paho.Message(val)
      message.destinationName = 'heartclock/alarm'
      this.client.send(message)
    }
  },
  data() {
    return {
      errorMsg: '',
      connection: {
        host: window.location.host.split(':')[0],
        // host: 'broker.mqttdashboard.com',
        port: 8000,
        endpoint: '/mqtt',
        clean: true, // Reserved session
        connectTimeout: 4000, // Time out
        reconnectPeriod: 4000, // Reconnection interval
        // Certification Information
        clientId: this.getDevice() + '_' + Math.random().toString(36).substring(7),
        username: 'emqx_test',
        password: 'emqx_test',
      },
      receiveNews: '',
      client: {
        connected: false,
      },
    }
  },
  mounted: function() {
    this.initWs()
  },
  methods: {
    initWs() {
      const { host, port, clientId, endpoint, ...options } = this.connection
      try {
        this.client = new Paho.Client(host, port, clientId)
      } catch (error) {
        this.errorMsg += error + '\n'
        console.log('mqtt.connect error', error)
      }

      this.client.connect({onSuccess: () => {
        console.log('Connection succeeded!')
        this.client.subscribe('heartclock/rate')
        this.client.subscribe('heartclock/time')
        this.client.subscribe('heartclock/alarm')


        var message = new Paho.Message(JSON.stringify({
          ua: navigator.userAgent,
          id: this.connection.clientId
        }))
        message.destinationName = 'heartclock/newclient'
        this.client.send(message)
      }})

      this.client.onConnectionLost = (responseObject) => {
        if (responseObject.errorCode !== 0) {
          console.log("onConnectionLost:"+responseObject.errorMessage);
        }
      }

      this.client.onMessageArrived = (message) => {
        // console.log(`${message.topic}: ${message.payloadString}`)
        // this.receiveNews = this.receiveNews.concat(message.payloadString)
        this.$emit(message.topic.replace('/', ''), message.payloadString)

      }
    },
    getDevice() {
      var res = 'browser'
      try {
        res = window.navigator.userAgent.split('(')[1].split(';')[0]
      } catch (e) {
        console.log(e)
      }
      return res
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
