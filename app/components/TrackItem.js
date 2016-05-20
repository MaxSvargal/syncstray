import React, { Component, PropTypes } from 'react'
import styles from './TrackItem.css'

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

    return (
      <div className={ styles.container }>
        <div className={ styles.bar } style={ { width: `${progressPerc}%` } } />
        <span>{ artist } - { title }</span>
        <span>{ progressPerc }%</span>
      </div>
    )
  }
}
