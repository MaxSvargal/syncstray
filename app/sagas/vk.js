import { call, take, put } from 'redux-saga/effects'
import { replace } from 'react-router-redux'
import { setVkToken, setVkUserId, setVkTracks } from 'actions'
import { fetchVkToken, fetchVkAudio } from 'services/vk'
import { SET_VK_AUTH_CODE, SET_VK_TOKEN } from 'actions/types'

export function* vkAuthSaga() {
  while (true) {
    const { code } = yield take(SET_VK_AUTH_CODE)
    try {
      const { accessToken, expiresIn, userId } = yield call(fetchVkToken, code)
      yield put(setVkToken(accessToken, expiresIn))
      yield put(setVkUserId(userId))
      yield put(replace('/selectDir'))
    } catch (err) {
      console.error(err)
    }
  }
}

export function* vkGetAudioSaga() {
  while (true) {
    const { token } = yield take(SET_VK_TOKEN)
    try {
      const tracks = yield call(fetchVkAudio, token)
      yield put(setVkTracks(tracks))
    } catch (err) {
      console.error(err)
    }
  }
}
