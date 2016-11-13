
export const SAVE_STATE = 'SAVE_STATE'

export function saveState(aid, state) {
  return { type: SAVE_STATE, aid, state }
}
