import React from 'react'
import { Route, IndexRoute } from 'react-router'
import App from 'containers/app'
import HomePage from 'containers/homePage'
import AuthPage from 'containers/authPage'
import AudioPage from 'containers/audioPage'
import SelectDirPage from 'containers/selectDirPage'

export default (
  <Route path='/' component={ App }>
    <IndexRoute component={ HomePage } />
    <Route path='/auth' component={ AuthPage } />
    <Route path='/audio' component={ AudioPage } />
    <Route path='/selectDir' component={ SelectDirPage } />
  </Route>
)
