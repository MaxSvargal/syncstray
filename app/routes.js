import React from 'react';
import { Route, IndexRoute } from 'react-router';
import App from './containers/App';
import HomePage from './containers/HomePage';
import CounterPage from './containers/CounterPage';
import AuthPage from './containers/AuthPage';
import AudioPage from './containers/AudioPage';

export default (
  <Route path="/" component={App}>
    <IndexRoute component={HomePage} />
    <Route path="/counter" component={CounterPage} />
    <Route path="/auth" component={AuthPage} />
    <Route path="/audio" component={AudioPage} />
  </Route>
);
