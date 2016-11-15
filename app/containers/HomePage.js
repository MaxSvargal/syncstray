import React, { Component } from 'react'
import { connect } from 'react-redux'
import Home from 'components/home'
import Audio from 'components/audio'

@connect(({ vk: { token } }) => ({ token }))
class HomePage extends Component {
  props: {
    token: string
  }

  render() {
    return (
      this.props.token ? <Audio /> : <Home />
    )
  }
}

export default HomePage
