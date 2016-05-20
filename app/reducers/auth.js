import { SET_CODE, SET_TOKEN } from '../actions/auth';

export function code(state = null, action) {
  return action.type === SET_CODE ? action.code : state;
}

export function token(state = null, action) {
  return action.type === SET_TOKEN ? action.token : state;
}
