// @flow
import React, { Component } from 'react'

export default class Auth extends Component {
  props: {
    setVkAuthCode: () => void
  }

  clientId = 4138123
  webview = {}

  onRedirect = (event: { newURL: string }) => {
    const [ , match ] = event.newURL.match(/#code=(\w+)/) || []
    if (match) this.props.setVkAuthCode(match)
  }

  componentDidMount() {
    this.webview.addEventListener('did-get-redirect-request', this.onRedirect)
  }

  componentWillUnmount() {
    this.webview.removeEventListener('did-get-redirect-request', this.onRedirect)
  }

  render() {
    const styles = this.getStyles()

    return (
      <div style={ styles.root }>
        <h1>Authorization....</h1>
        <webview
          src={ `https://oauth.vk.com/authorize?client_id=${this.clientId}&scope=audio&response_type=code` }
          ref={ c => (this.webview = c) }
          style={ styles.webView } />
      </div>
    )
  }

  getStyles() {
    return {
      root: {
        width: '100vw',
        height: '100vh',
        display: 'flex',
        flexFlow: 'column wrap',
        alignItems: 'center',
        justifyContent: 'center'
      },
      webView: {
        position: 'absolute',
        top: 0,
        left: 0,
        width: '100vw',
        height: '100vh'
      }
    }
  }
}
