import { fork } from 'child_process'

const dlThreads = 4
const workerPath = './app/utils/download_worker.js'
const getDestPath = (dlpath, artist, title) =>
  `${dlpath}/${artist} - ${title}.mp3`

export const DL_WORKER = 'DL_WORKER'
export const DL_NEXT = 'DL_NEXT'
export const DL_START = 'DL_START'
export const DL_PAUSE = 'DL_PAUSE'

export function addWorker(id, worker) {
  return { type: DL_WORKER, id, worker }
}

export function pushDownload() {
  return { type: DL_NEXT }
}

export function pauseDownload() {
  return { type: DL_PAUSE }
}

export function resumeDownload() {
  return { type: DL_START }
}

export function downloadNext() {
  return (dispatch, getState) => {
    const { audio, queue } = getState()
    dispatch(download(audio[queue]))
    dispatch(pushDownload())
  }
}

export function download({ aid, artist, title, url }) {
  return (dispatch, getState) => {
    const { dlpath } = getState()
    const worker = fork(workerPath, [url, getDestPath(dlpath, artist, title)])
    dispatch(addWorker(aid, worker))
    worker.on('message', ({ progress }) => {
      if (parseInt(progress, 10) === 1) {
        const { dlState } = getState()
        dlState === true && dispatch(downloadNext())
      }
    })
  }
}

export function startDownload() {
  return dispatch => {
    dispatch(resumeDownload())
    for (let i = 0; i < dlThreads; i++) {
      dispatch(downloadNext())
    }
  }
}
