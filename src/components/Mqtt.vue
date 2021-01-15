
<template>

  <div class="Mqtt">
  </div>
</template>

<script>

import mqtt from 'mqtt'

export default {
  name: 'Mqtt',
  props: { 
    alarmtime: String,
  },
  watch:{
    alarmtime(val) {
      this.client.publish('heartclock/alarm', val)
    }
  },
  data() {
    return {
      connection: {
        host: '',
        port: 8000,
        endpoint: '/mqtt',
        clean: true, // Reserved session
        connectTimeout: 4000, // Time out
        reconnectPeriod: 4000, // Reconnection interval
        // Certification Information
        clientId: 'web' + Math.random().toString(36).substring(7),
        username: 'emqx_test',
        password: 'emqx_test',
      },
      subscription: {
        topic: 'topic/mqttx',
        qos: 0,
      },
      publish: {
        topic: 'topic/browser',
        qos: 0,
        payload: '{ "msg": "Hello, I am browser." }',
      },
      receiveNews: '',
      qosList: [
        { label: 0, value: 0 },
        { label: 1, value: 1 },
        { label: 2, value: 2 },
      ],
      client: {
        connected: false,
      },
      subscribeSuccess: false,
    }
  },
  mounted: function() {
    const { host, port, endpoint, ...options } = this.connection
    const connectUrl = `ws://${host}:${port}${endpoint}`
    try {
      this.client = mqtt.connect(connectUrl, options)
    } catch (error) {
      console.log('mqtt.connect error', error)
    }
    this.client.on('connect', () => {
      console.log('Connection succeeded!')
      this.client.subscribe('heartclock/rate')
      this.client.subscribe('heartclock/time')
      this.client.subscribe('heartclock/alarm')

      this.client.publish('heartclock/newclient', JSON.stringify({
        ua: navigator.userAgent,
        id: this.connection.clientId
      }))
    })
    this.client.on('error', error => {
      console.log('Connection failed', error)
    })
    this.client.on('message', (topic, message) => {
      this.receiveNews = this.receiveNews.concat(message)
      // console.log(`Received message ${message} from topic ${topic}`)
      this.$emit(topic.replace('/', ''), message.toString())
    })
  },
  methods: {
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
