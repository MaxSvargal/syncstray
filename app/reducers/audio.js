import { SET_AUDIO } from '../actions/api'
import { DL_WORKER, DL_NEXT } from '../actions/downloader'

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
