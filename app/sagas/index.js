import { fork } from 'redux-saga/effects'
import { vkAuthSaga, vkGetAudioSaga } from './vk'
import { initialDownloadTracks, downloadNextWatcher, workersPauseWatcher, workersCheckIssetOnResume } from './downloader'

export default function* root() {
  yield [
    fork(vkAuthSaga),
    fork(vkGetAudioSaga),
    fork(initialDownloadTracks),
    fork(downloadNextWatcher),
    fork(workersPauseWatcher),
    fork(workersCheckIssetOnResume)
  ]
}
