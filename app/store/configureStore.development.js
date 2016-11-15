import { createStore, applyMiddleware, compose } from 'redux'
import createSagaMiddleware from 'redux-saga'
import { hashHistory } from 'react-router'
import { routerMiddleware, push } from 'react-router-redux'
import createLogger from 'redux-logger'
import rootReducer from 'reducers'
import rootSaga from 'sagas'

const actionCreators = {
  push
}

const logger = createLogger({
  level: 'info',
  collapsed: true
})

const router = routerMiddleware(hashHistory)
const sagaMiddleware = createSagaMiddleware()

// If Redux DevTools Extension is installed use it, otherwise use Redux compose
/* eslint-disable no-underscore-dangle */
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({
    // Options: http://zalmoxisus.github.io/redux-devtools-extension/API/Arguments.html
    actionCreators,
  }) :
  compose
/* eslint-enable no-underscore-dangle */
const enhancer = composeEnhancers(
  applyMiddleware(sagaMiddleware, router, logger)
)

export default function configureStore(initialState: Object) {
  const store = createStore(rootReducer, initialState, enhancer)
  sagaMiddleware.run(rootSaga)

  if (module.hot) {
    module.hot.accept('../reducers', () =>
      store.replaceReducer(require('../reducers')) // eslint-disable-line global-require
    )
  }

  return store
}
