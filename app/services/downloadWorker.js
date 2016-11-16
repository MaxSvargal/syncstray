/* eslint no-unused-vars: 0 */
const [ bin, exec, url, dist ] = process.argv
const fs = require('fs')
const https = require('https')

const file = fs.createWriteStream(dist)
const httpsUrl = url.replace(/^http:\/\//i, 'https://')

https.get(httpsUrl, resp => {
  resp.pipe(file)

  const len = parseInt(resp.headers['content-length'], 10)
  let downloaded = 0
  let latestVal = 0

  resp.on('data', ({ length }) => {
    downloaded += length
    const currVal = (downloaded / len).toFixed(2)
    if (currVal !== latestVal) process.send({ progress: (downloaded / len).toFixed(2) })
    latestVal = currVal
  })

  resp.on('end', () => {
    file.close()
    process.exit(0)
  })

  process.on('message', msg => {
    switch (msg) {
      case 'pause':
        return resp.pause()
      case 'resume':
        return resp.resume()
      default:
        break
    }
  })
}).on('error', error => {
  fs.unlink(file)
  process.send({ error })
  process.exit(1)
})
