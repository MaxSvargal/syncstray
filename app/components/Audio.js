import React, { Component, PropTypes } from 'react'
import { Link } from 'react-router'

import TracksList from './TracksList'

export default class Audio extends Component {
  static propTypes = {
    audio: PropTypes.array.isRequired,
    workers: PropTypes.object.isRequired,
    getAudio: PropTypes.func.isRequired,
    startDownload: PropTypes.func.isRequired
  };

  componentWillMount() {
    this.props.getAudio()
  }

  download = () => {
    this.props.startDownload()
  }

  render() {
    const { workers, audio } = this.props
    return (
      <div>
        <Link to="/">Go home</Link>
        <button onClick={ this.download }>Download</button>
        <TracksList collection={ audio } workers={ workers } />
      </div>
    )
  }
}
