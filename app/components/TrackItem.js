import React, { Component } from 'react'
import radium from 'radium'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { saveState } from '../actions/trackState'

@connect((state, ownProps) => ({
  worker: state.workers[ownProps.model.aid],
  state: state.progresStates[ownProps.model.aid]
}), dispatch => bindActionCreators({ saveState }, dispatch))
@radium
export default class TrackItem extends Component {
  props: {
    worker: {},
    state: {},
    model: {
      aid: number,
      artist: string,
      title: string
    },
    onDownloadEnd: Function,
    saveState: Function
  }

  state = this.props.state || {
    progress: 0
  }

  mounted = false

  componentWillMount() {
    this.mounted = true
  }

  componentWillUnmount() {
    this.mounted = false
    this.props.saveState(this.props.model.aid, this.state)
  }

  progressStateHandler = ({ progress }) => {
    this.mounted &&
      this.setState({ progress: parseFloat(progress) })
  }

  componentWillReceiveProps({ worker, state }) {
    (worker && !this.props.worker) &&
      worker.on('message', this.progressStateHandler)
    state && this.setState(state)
  }

  componentDidUpdate() {
    this.state.progress === 1 &&
      this.props.onDownloadEnd(this.props.model.aid)
  }

  render() {
    const { model: { artist, title } } = this.props
    const { progress } = this.state
    const progressPerc = (progress * 100).toFixed(0)
    const styles = this.getStyles()

    return (
      <div style={ styles.container }>
        <div
          style={ [
            styles.bar,
            progressPerc > 0 && styles.barProgress,
            progressPerc >= 99 && styles.barComplete,
            { width: `${progressPerc}%` }] } />
        <span
          style={ [
            styles.content,
            progressPerc > 0 && styles.contentProgress,
            progressPerc === 100 && styles.contentComplete] }>
          { artist } - { title }
        </span>
        <span style={ styles.perc }>{ progressPerc }%</span>
      </div>
    )
  }

  getStyles() {
    return {
      container: {
        position: 'relative',
        padding: '.8rem 1rem',
        height: 42,
        boxSizing: 'border-box',
        borderBottom: '1px solid #333645',
        marginBottom: 1,
        lineHeight: '1rem'
      },
      bar: {
        height: 42,
        zIndex: 1,
        top: 0,
        left: 0,
        transition: 'width .6s',
        position: 'absolute',
        background: '#323b48',
        borderBottom: '1px solid #1f252c'
      },
      barProgress: {
        background: 'linear-gradient(to right, #fd3d3c, #ff7a77)',
        boxShadow: '0 -2px 0 #ff605d'
      },
      barComplete: {
        background: '#323b48',
        borderBottom: '1px solid #3c444e',
        boxShadow: 'none'
      },
      content: {
        zIndex: 2,
        position: 'relative',
        color: '#a6a7ac'
      },
      contentProgress: {
        color: '#fff',
        textShadow: '0 0 2px #141527'
      },
      contentComplete: {
        color: '#a6a7ac'
      },
      perc: {
        position: 'relative',
        zIndex: 3,
        float: 'right',
        color: '#fff',
        textShadow: '0 0 2px #141527',
        fontSize: '.8em'
      }
    }
  }
}
