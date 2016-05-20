import { get } from 'axios'

export const SET_AUDIO = 'SET_AUDIO'

export function setAudio(audio = []) {
  return { type: SET_AUDIO, audio }
}

export function getAudio() {
  return (dispatch, getState) => {
    const { token } = getState()
    get(`https://api.vk.com/method/audio.get?access_token=${token}`)
      .then(({ data: { response } }) =>
        dispatch(setAudio(response)))
  }
}
