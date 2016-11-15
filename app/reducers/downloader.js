import { combineReducers } from 'redux'
import {
  DOWNLOAD_NEXT, SET_DOWNLOAD_PROGRESS, SET_DL_WORKER, REMOVE_DL_WORKER,
  SELECT_DOWNLOAD_DIR, TOGGLE_PAUSE_DOWNLOAD, SET_DOWNLOAD_THREADS
} from 'actions/types'

export const threads = (state = 4, { type, value }) =>
  type === SET_DOWNLOAD_THREADS ? value : state

export const paused = (state = false, { type }) =>
  type === TOGGLE_PAUSE_DOWNLOAD ? !state : state

export const dlIndex = (state = -1, { type }) =>
  type === DOWNLOAD_NEXT ? state + 1 : state

export const dlDir = (state = null, { type, directory }) =>
  type === SELECT_DOWNLOAD_DIR ? directory : state

export const progresses = (state = {}, { type, aid, progress }) =>
  type === SET_DOWNLOAD_PROGRESS ? { ...state, [aid]: progress } : state

export const workers = (state = {}, { type, aid, worker }) => {
  switch (type) {
    case SET_DL_WORKER: return { ...state, [aid]: worker }
    case REMOVE_DL_WORKER: return { ...state, [aid]: false }
    default: return state
  }
}

export default combineReducers({ dlIndex, dlDir, paused, workers, progresses, threads })
