import { get } from 'axios';

export const SET_CODE = 'SET_CODE';
export const SET_TOKEN = 'SET_TOKEN';

export function setCode(code) {
  return { type: SET_CODE, code };
}

export function setToken(token) {
  return { type: SET_TOKEN, token };
}

export function getToken() {
  return (dispatch, getState) => {
    const { code } = getState();
    get(`https://oauth.vk.com/access_token?client_id=4138123&client_secret=9c7G6T5bZkVE097J3AMI&code=${code}`)
      .then(resp => dispatch(setToken(resp.data.access_token)));
  };
}

export function setVkAuthCode(code) {
  return dispatch => {
    dispatch(setCode(code));
    dispatch(getToken());
  };
}
