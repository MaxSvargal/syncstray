import React, { Component } from 'react'
import LazyList from 'components/LazyList'
import TrackItem from 'components/trackItem'

export default class Audio extends Component {
  props: {
    tracks: {}[],
    token: string,
    togglePauseDownload: () => void,
    setDlProgress: () => void,
    replace: () => void
  }

  computedChildren = []

  componentWillMount() {
    if (!this.props.token) this.props.replace('/')
  }

  componentWillReceiveProps(props) {
    const { tracks, setDlProgress } = props

    if (tracks.length !== this.props.tracks) {
      this.computedChildren = tracks.map((track, index) =>
        <TrackItem { ...track } setProgress={ setDlProgress } key={ index } />)
    }
  }

  shouldComponentUpdate(props) {
    return props.tracks.length !== this.props.tracks.length
  }

  render() {
    const { togglePauseDownload } = this.props
    const styles = this.getStyles()

    return (
      <div>
        { this.computedChildren.length > 0 ?
          <div style={ styles.rootContainer }>
            <div style={ styles.actions } >
              <button
                onClick={ togglePauseDownload }
                style={ styles.btn } >
                  Pause
              </button>
            </div>
            <LazyList
              windowHeight={ window.innerHeight }
              elementHeight={ 49 }
              topScrollOffset={ 50 }
              bottomScrollOffset={ 0 } >
              { this.computedChildren }
            </LazyList>
          </div>
          :
          <div style={ styles.msgContainer }>
            <h1>Loading audio tracks...</h1>
          </div>
        }
      </div>
    )
  }

  getStyles() {
    return {
      rootContainer: {
        paddingTop: 70
      },
      msgContainer: {
        width: '100vw',
        height: '100vh',
        display: 'flex',
        flexFlow: 'column wrap',
        alignItems: 'center',
        justifyContent: 'center'
      },
      actions: {
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        height: 40,
        padding: '1rem',
        zIndex: 20,
        background: '#fff'
      },
      btn: {
        fontSize: '1.25rem',
        padding: '.5rem 1rem',
        color: 'white',
        background: 'black',
        border: 0
      }
    }
  }
}
