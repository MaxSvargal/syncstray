import Immutable from 'immutable'

import { SET_AUDIO } from '../actions/api'
import { DL_WORKER, DL_NEXT, DL_START, DL_PAUSE, SET_PROGRESS } from '../actions/downloader'
import { SAVE_STATE } from '../actions/trackState'

const immutableAudioState = new Immutable.List()

export function audio(state = immutableAudioState, action) {
  return action.type === SET_AUDIO ?
    new Immutable.List(action.audio) : state
}

export function workers(state = {}, action) {
  return action.type === DL_WORKER ?
    { ...state, [action.id]: action.worker } : state
}

export function queue(state = 0, action) {
  return action.type === DL_NEXT ? state + 1 : state
}

export function dlState(state = true, action) {
  switch (action.type) {
    case DL_START:
      return true
    case DL_PAUSE:
      return false
    default:
      return state
  }
}

export function progresStates(state = {}, action) {
  switch (action.type) {
    case SET_PROGRESS:
      return { ...state, [action.aid]: { progress: action.progress } }
    case SAVE_STATE:
      return { ...state, [action.aid]: action.state }
    default:
      return state
  }
}
