import { SET_AUDIO } from '../actions/api'
import { DL_WORKER, DL_NEXT, DL_START, DL_PAUSE } from '../actions/downloader'

export function audio(state = [], action) {
  return action.type === SET_AUDIO ? action.audio : state
}

export function workers(state = {}, action) {
  return action.type === DL_WORKER ?
    Object.assign({}, state, { [action.id]: action.worker }) : state
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
