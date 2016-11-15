import { createStore, applyMiddleware } from 'redux'
import createSagaMiddleware from 'redux-saga'
import { hashHistory } from 'react-router'
import { routerMiddleware } from 'react-router-redux'
import rootReducer from 'reducers'
import rootSaga from 'sagas'

const router = routerMiddleware(hashHistory)
const sagaMiddleware = createSagaMiddleware()

const enhancer = applyMiddleware(sagaMiddleware, router)

export default function configureStore(initialState: Object) {
  const store = createStore(rootReducer, initialState, enhancer)
  sagaMiddleware.run(rootSaga)
  return store
}
