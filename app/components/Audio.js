import React, { Component, PropTypes } from 'react'
import { Link } from 'react-router'
const { app, dialog } = require('electron').remote

import TracksList from './TracksList'

export default class Audio extends Component {
  static propTypes = {
    audio: PropTypes.array.isRequired,
    workers: PropTypes.object.isRequired,
    getAudio: PropTypes.func.isRequired,
    startDownload: PropTypes.func.isRequired,
    pauseDownload: PropTypes.func.isRequired,
    setDlPath: PropTypes.func.isRequired
  };

  componentWillMount() {
    this.props.getAudio()
  }

  componentDidMount() {
    const { setDlPath } = this.props
    const selectFolder = () => {
      dialog.showOpenDialog({
        properties: ['openDirectory'],
        title: 'Please, choose directory for download',
        defaultPath: app.getPath('music')
      }, folders =>
        (folders ? setDlPath(folders[0]) : selectFolder()))
    }
    selectFolder()
  }

  download = () => this.props.startDownload()
  pause = () => this.props.pauseDownload()

  render() {
    const { workers, audio } = this.props
    return (
      <div>
        <Link to="/">Go home</Link>
        <button onClick={ this.download }>Download</button>
        <button onClick={ this.pause }>Pause</button>
        <TracksList collection={ audio } workers={ workers } />
      </div>
    )
  }
}
