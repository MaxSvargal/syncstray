import React, { Component } from 'react'
import { connect } from 'react-redux'

@connect(({ downloader: { workers, progresses } }, { aid }) =>
  ({ worker: workers[aid], progress: progresses[aid] }))
class TrackItem extends Component {
  props: {
    aid: number,
    artist: string,
    title: string,
    progress: bool,
    worker: ?{},
    setProgress: () => void
  }

  state = {
    progress: this.props.progress || 0
  }

  workerProgressListener = ({ progress }) =>
    this.setState({ progress })

  componentWillMount() {
    this.props.worker &&
      this.props.worker.addListener('message', this.workerProgressListener)
  }

  componentWillReceiveProps(props) {
    props.worker &&
      props.worker.addListener('message', this.workerProgressListener)
  }

  componentWillUnmount() {
    const { aid, worker, setProgress } = this.props
    const { progress } = this.state
    worker && worker.removeListener('message', this.workerProgressListener)
    progress > 0 && progress < 1 && setProgress(aid, progress)
  }

  render() {
    const { artist, title } = this.props
    const { progress } = this.state
    const styles = this.getStyles()

    return (
      <div style={ styles.container } >
        <div style={ styles.progressBar(progress) } />
        <div style={ styles.label }>{ artist } - { title }</div>
      </div>
    )
  }

  getStyles() {
    return {
      container: {
        height: '3rem',
        position: 'relative',
        borderBottom: '1px solid #999'
      },
      progressBar: (progress) => ({
        background: '#e0e0e0',
        width: `${(progress * 100).toFixed(0)}%`,
        height: '100%'
      }),
      label: {
        position: 'absolute',
        top: 0,
        left: 0,
        padding: '0 1rem',
        height: '3rem',
        lineHeight: '3rem',
        zIndex: 10,
        overflow: 'hidden',
        boxSizing: 'border-box'
      }
    }
  }
}

export default TrackItem
