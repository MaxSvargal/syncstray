import { combineReducers } from 'redux'
import { SET_VK_AUTH_CODE, SET_VK_TOKEN, SET_VK_TRACKS } from 'actions/types'

export const code = (state = null, action) =>
  action.type === SET_VK_AUTH_CODE ? action.code : state

export const token = (state = null, action) =>
  action.type === SET_VK_TOKEN ? action.token : state

export const expiresIn = (state = null, action) =>
  action.type === SET_VK_TOKEN ? action.expiresIn : state

export const tracks = (state = [], action) =>
  action.type === SET_VK_TRACKS ? action.tracks : state

export default combineReducers({ code, token, expiresIn, tracks })
