import { SET_DLPATH } from '../actions/folder'

export function dlpath(state = '', action) {
  return action.type === SET_DLPATH ? action.path : state
}
