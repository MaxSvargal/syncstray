// @flow
import { combineReducers } from 'redux'
import { routerReducer as routing } from 'react-router-redux'
import vk from './vk'
import downloader from './downloader'

const rootReducer = combineReducers({
  routing,
  downloader,
  vk
})

export default rootReducer
