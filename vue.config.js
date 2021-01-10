module.exports = {
  lintOnSave: false,
  devServer: {
    // before: require('./server.js')
    // proxy: 'http://localhost:3000',
    // host: '0.0.0.0'
    proxy: {
      '^/': {
        target: 'http://localhost:3000',
        ws: true,
        changeOrigin: true
      },
    }
  },
}
