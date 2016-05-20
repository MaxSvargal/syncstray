import { combineReducers } from 'redux'
import { routerReducer as routing } from 'react-router-redux'
import { code, token } from './auth'
import { audio, workers, queue } from './audio'

const rootReducer = combineReducers({
  routing, code, token, audio, workers, queue
})

export default rootReducer
