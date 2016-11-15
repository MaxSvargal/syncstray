import * as actions from 'actions/types'

const action = (type, payload = {}) => ({ type, ...payload })

export const setVkAuthCode = (code: string) =>
  action(actions.SET_VK_AUTH_CODE, { code })

export const setVkToken = (token: string, expiresIn: number) =>
  action(actions.SET_VK_TOKEN, { token, expiresIn })

export const setVkUserId = (id: number) =>
  action(actions.SET_VK_USER_ID, { id })

export const setVkTracks = (tracks: []) =>
  action(actions.SET_VK_TRACKS, { tracks })

export const downloadNext = () =>
  action(actions.DOWNLOAD_NEXT)

export const setDlProgress = (aid, progress) =>
  action(actions.SET_DOWNLOAD_PROGRESS, { aid, progress })

export const alreadyExist = () =>
  action(actions.ALREADY_EXIST)

export const setDlWorker = (aid, worker) =>
  action(actions.SET_DL_WORKER, { aid, worker })

export const removeDlWorker = aid =>
  action(actions.REMOVE_DL_WORKER, { aid })

export const togglePauseDownload = () =>
  action(actions.TOGGLE_PAUSE_DOWNLOAD)

export const selectDlDir = directory =>
  action(actions.SELECT_DOWNLOAD_DIR, { directory })
