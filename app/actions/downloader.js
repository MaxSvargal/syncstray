import { fork } from 'child_process'
import { access, F_OK } from 'fs'

const dlThreads = 3
const workerPath = './app/utils/download_worker.js'

const filterSymbols = str =>
  str.replace(/[><|"\?\*:\/\\]/g, '')

const getDestPath = (dlpath, artist, title) =>
  `${dlpath}/${filterSymbols(artist)} - ${filterSymbols(title)}.mp3`

export const DL_WORKER = 'DL_WORKER'
export const DL_NEXT = 'DL_NEXT'
export const DL_START = 'DL_START'
export const DL_PAUSE = 'DL_PAUSE'
export const SET_PROGRESS = 'SET_PROGRESS'

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
export function setProgress(aid, progress) {
  return { type: SET_PROGRESS, aid, progress }
}

export function downloadNext() {
  return (dispatch, getState) => {
    const { audio, queue } = getState()
    dispatch(download(audio.get(queue)))
    dispatch(pushDownload())
  }
}

export function download({ aid, artist, title, url }) {
  const checkFileIsset = (path, success, fail) =>
    access(path, F_OK, err => (err ? fail() : success()))

  return (dispatch, getState) => {
    const { dlpath } = getState()
    const dest = getDestPath(dlpath, artist, title)

    checkFileIsset(dest, () => {
      const { dlState } = getState()
      dispatch(setProgress(aid, 1))
      dlState && dispatch(downloadNext())
    }, () => {
      const worker = fork(workerPath, [url, dest])
      dispatch(addWorker(aid, worker))
      worker.on('message', ({ progress }) => {
        if (parseInt(progress, 10) === 1) {
          const { dlState } = getState()
          dlState && dispatch(downloadNext())
        }
      })
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
