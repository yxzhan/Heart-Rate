<template>
  <div id="app">
    <HeartBeat/>
  </div>
</template>

<script>
import HeartBeat from './components/HeartBeat.vue'

export default {
  name: 'App',
  meta: { keepAlive: true },
  components: {
    HeartBeat
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  /* margin-top: 60px; */
}
html,body{
  padding:0;
  margin: 0;
}
</style>
