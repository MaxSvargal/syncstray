import React, { Component } from 'react'
import { Link } from 'react-router'
const { app, dialog } = require('electron').remote

import TracksList from './TracksList'

export default class Audio extends Component {
  props: {
    audio: [],
    workers: {},
    getAudio: () => void,
    startDownload: () => void,
    pauseDownload: () => void,
    setDlPath: () => void,
  }

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

  render() {
    const { workers, audio, scrolled } = this.props
    const { startDownload, pauseDownload, triggerScroll } = this.props
    return (
      <div>
        <Link to="/">Go home</Link>
        <button onClick={ startDownload }>Download</button>
        <button onClick={ pauseDownload }>Pause</button>
        <TracksList
          collection={ audio }
          workers={ workers } />
      </div>
    )
  }
}
