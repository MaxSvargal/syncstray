import React, { Component, PropTypes } from 'react';
import styles from './Auth.css';

export default class Auth extends Component {
  static propTypes = {
    setVkAuthCode: PropTypes.func.isRequired
  };

  static contextTypes = {
    router: PropTypes.object.isRequired
  };

  componentDidMount() {
    this.refs.vkview
      .addEventListener('did-get-redirect-request', event => {
        const matches = event.newURL.match(/#code=(\w+)/);
        if (matches && matches[1]) {
          this.props.setVkAuthCode(matches[1]);
          this.context.router.push('/');
        }
      });
  }

  render() {
    return (
      <div>
        <div className={styles.container}>
          <webview
            className={styles.vkview}
            src="https://oauth.vk.com/authorize?client_id=4138123&scope=audio&response_type=code"
            ref="vkview"
          />
        </div>
      </div>
    );
  }
}
