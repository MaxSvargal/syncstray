import React, { Component, PropTypes } from 'react'
import radium from 'radium'

@radium
export default class TrackItem extends Component {
  static propTypes = {
    model: PropTypes.object.isRequired,
    worker: PropTypes.object
  };

  state = {
    progress: 0
  }

  componentWillReceiveProps({ worker }) {
    worker && worker.on('message', ({ progress }) =>
      this.setState({ progress }))
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
            { width: `${progressPerc}%` }] } />
        <span
          style={ [
            styles.content,
            progressPerc > 0 && styles.contentProgress,
            progressPerc === 100 && styles.contentComplete] }>
          { artist } - { title }
        </span>
        <span>{ progressPerc }%</span>
      </div>
    )
  }

  getStyles() {
    return {
      container: {
        position: 'relative',
        padding: '.8rem 1rem',
        borderBottom: '1px solid #333645'
      },
      bar: {
        height: '3rem',
        zIndex: 1,
        top: 0,
        left: 0,
        transition: 'width .6s',
        position: 'absolute',
        background: '#323b48',
        outline: '1px solid #1f252c'
      },
      barProgress: {
        background: 'linear-gradient(to right, #fd3d3c, #ff7a77)',
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
      }
    }
  }
}
