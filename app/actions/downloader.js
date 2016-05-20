import { fork } from 'child_process'

const dlThreads = 4
const workerPath = './app/utils/download_worker.js'
const getDestPath = (artist, title) => `./cache/${artist} - ${title}.mp3`

export const DL_WORKER = 'DL_WORKER'
export const DL_NEXT = 'DL_NEXT'

export function addWorker(id, worker) {
  return { type: DL_WORKER, id, worker }
}

export function pushDownload() {
  return { type: DL_NEXT }
}

export function downloadNext() {
  return (dispatch, getState) => {
    const { audio, queue } = getState()
    dispatch(download(audio[queue]))
    dispatch(pushDownload())
  }
}

export function download({ aid, artist, title, url }) {
  return dispatch => {
    const worker = fork(workerPath, [url, getDestPath(artist, title)])
    dispatch(addWorker(aid, worker))
    worker.on('message', ({ progress }) => {
      progress === '1.00' && dispatch(downloadNext())
    })
  }
}

export function startDownload() {
  return dispatch => {
    for (let i = 0; i < dlThreads; i++) {
      dispatch(downloadNext())
    }
  }
}
