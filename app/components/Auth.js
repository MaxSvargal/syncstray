import React, { Component } from 'react'
import styles from './Auth.css'

export default class Auth extends Component {
  props: {
    setVkAuthCode: () => void
  };

  static contextTypes = {
    router: Object
  }

  componentDidMount() {
    this.refs.vkview
      .addEventListener('did-get-redirect-request', event => {
        const [, match] = event.newURL.match(/#code=(\w+)/) || []
        if (match) {
          this.props.setVkAuthCode(match)
          this.context.router.push('/')
        }
      })
  }

  render() {
    return (
      <div>
        <div className={ styles.container }>
          <h1>Authorization....</h1>
          <webview
            className={ styles.vkview }
            src="https://oauth.vk.com/authorize?client_id=4138123&scope=audio&response_type=code"
            ref="vkview" />
        </div>
      </div>
    )
  }
}
