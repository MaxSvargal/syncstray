/* eslint no-unused-vars: 0 */
const [ bin, exec, url, dist ] = process.argv
const fs = require('fs')
const https = require('https')

const file = fs.createWriteStream(dist)
const httpsUrl = url.replace(/^http:\/\//i, 'https://')

function errorHandle({ message }) {
  fs.unlinkSync(dist)
  process.send({ error: message })
  process.exit(1)
}

const timeoutTimer = {
  timer: null,
  update() {
    this.clear()
    this.timer = setTimeout(() =>
      errorHandle({ message: 'timeout' }), 3000)
  },
  clear() {
    clearTimeout(this.timer)
  }
}

timeoutTimer.update()

https.get(httpsUrl, resp => {
  resp.pipe(file)

  const len = parseInt(resp.headers['content-length'], 10)
  let downloaded = 0
  let latestVal = 0

  resp.on('data', chunk => {
    downloaded += chunk.length
    const currVal = (downloaded / len).toFixed(2)
    if (currVal !== latestVal) process.send({ progress: (downloaded / len).toFixed(2) })
    latestVal = currVal
    timeoutTimer.update()
  })

  resp.on('end', () => {
    file.close()
    timeoutTimer.clear()
    process.exit(0)
  })

  resp.on('error', errorHandle)

  process.on('message', msg => {
    switch (msg) {
      case 'pause':
        return timeoutTimer.clear() || resp.pause()
      case 'resume':
        return timeoutTimer.update() || resp.resume()
      default:
        break
    }
  })
}).on('error', errorHandle)
