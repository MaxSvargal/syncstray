import { combineReducers } from 'redux'
import { routerReducer as routing } from 'react-router-redux'
import { code, token } from './auth'
import { audio, workers, queue, dlState, progresStates } from './audio'
import { dlpath } from './dlfolder'

const rootReducer = combineReducers({
  routing, code, token, audio, workers, queue, dlpath, dlState, progresStates
})

export default rootReducer
