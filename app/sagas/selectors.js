export const getCurrentDlIndex = state => state.downloader.dlIndex
export const getTrackByIndex = (state, index) => state.vk.tracks[index]
export const dlIsPaused = state => state.downloader.paused
export const getDlThreads = state => state.downloader.threads
export const getDlWorkers = state =>
  Object.values(state.downloader.workers).filter(val => val !== false)
