import { accessSync, F_OK } from 'fs'
import path from 'path'
import childProcess from 'child_process'
import { remote } from 'electron'

import { eventChannel, END } from 'redux-saga'
import { take, fork, put, select, call } from 'redux-saga/effects'
import { replace } from 'react-router-redux'
import { downloadNext, setDlProgress, setDlWorker, removeDlWorker } from 'actions'
import { getCurrentDlIndex, getTrackByIndex, dlIsPaused, getDlWorkers, getDlThreads, getDlDir } from 'sagas/selectors'
import { SET_VK_TRACKS, DOWNLOAD_NEXT, TOGGLE_PAUSE_DOWNLOAD, SELECT_DOWNLOAD_DIR } from 'actions/types'

const workerPath = process.env.NODE_ENV === 'production' ?
  path.join(remote.app.getAppPath(), 'services/downloadWorker.js') :
  './app/services/downloadWorker.js'

/* Helpers */

/* eslint no-useless-escape: 0 */
const filterSymbols = str => str.replace(/[><|"\?\*:\/\\]/g, '')

const getDestPath = (dlPath, artist, title) =>
  `${dlPath}/${filterSymbols(artist)} - ${filterSymbols(title)}.mp3`

export function workerProgressEndChannel(worker) {
  return eventChannel(emitter => {
    function listener({ progress, error }) {
      if (error) emitter({ error })
      if (parseInt(progress, 10) === 1) {
        worker.removeListener('message', listener)
        emitter(END)
      }
    }
    worker.addListener('message', listener)
    return () => worker.removeListener('message', listener)
  })
}

/* Sagas for fork() */

export function* watchWorkerEndProgress(aid, worker) {
  const chan = yield call(workerProgressEndChannel, worker)
  try {
    while (true) {
      const { error } = yield take(chan)
      if (error) yield put({ type: 'ERROR', error, aid })
    }
  } finally {
    yield put(removeDlWorker(aid))
    yield put(setDlProgress(aid, 1))
    yield put(downloadNext())
  }
}

export function* downloadTrack({ aid, artist, title, url }) {
  const dlPath = yield select(getDlDir)
  const dest = getDestPath(dlPath, artist, title)
  try {
    accessSync(dest, F_OK)
    yield put(setDlProgress(aid, 1))
    yield put(downloadNext())
  } catch (err) {
    const worker = childProcess.fork(workerPath, [ url, dest ])
    yield put(setDlWorker(aid, worker))
    yield fork(watchWorkerEndProgress, aid, worker)
  }
}

/* Watch sagas */

export function* initialDownloadTracks() {
  while (yield take(SET_VK_TRACKS)) {
    const threads = yield select(getDlThreads)
    const dlDir = yield select(getDlDir)
    if (!dlDir) {
      yield take(SELECT_DOWNLOAD_DIR)
      yield put(replace('/audio'))
    }

    for (let i = 0; i < threads; i += 1) {
      yield put(downloadNext())
    }
  }
}

export function* downloadNextWatcher() {
  while (yield take(DOWNLOAD_NEXT)) {
    if (!(yield select(dlIsPaused))) {
      const index = yield select(getCurrentDlIndex)
      const track = yield select(getTrackByIndex, index)
      yield fork(downloadTrack, track)
    }
  }
}

export function* workersPauseWatcher() {
  while (yield take(TOGGLE_PAUSE_DOWNLOAD)) {
    const workers = yield select(getDlWorkers)
    const isPaused = yield select(dlIsPaused)
    const task = isPaused ? 'pause' : 'resume'
    workers.forEach(worker => worker.connected && worker.send(task))
  }
}

export function* workersCheckIssetOnResume() {
  while (yield take(TOGGLE_PAUSE_DOWNLOAD)) {
    const workers = yield select(getDlWorkers)
    const threads = yield select(getDlThreads)

    if (workers.length < threads) {
      for (let i = 0; i < threads - workers.length; i += 1) {
        yield put(downloadNext())
      }
    }
  }
}
