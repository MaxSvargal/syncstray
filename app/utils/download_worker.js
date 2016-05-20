/* eslint no-unused-vars: 0 */
const [bin, exec, url, dist] = process.argv;
const fs = require('fs');
const https = require('https');

const file = fs.createWriteStream(dist);

https.get(url, resp => {
  resp.pipe(file);

  const len = parseInt(resp.headers['content-length'], 10);
  let downloaded = 0;
  let latestVal = 0;

  resp.on('data', ({ length }) => {
    downloaded += length;
    const currVal = (downloaded / len).toFixed(2);
    if (currVal !== latestVal)
      process.send({ progress: (downloaded / len).toFixed(2) });
    latestVal = currVal;
  });
  resp.on('end', () => {
    file.close();
    process.exit(0);
  });
}).on('error', error => {
  fs.unlink(file);
  process.send({ error });
  process.exit(1);
});
