import React, { Component, PropTypes } from 'react'
import Infinite from 'react-infinite'
import TrackItem from './TrackItem'
import styles from './TracksList.css'

export default class TracksList extends Component {
  static propTypes = {
    collection: PropTypes.array.isRequired,
    workers: PropTypes.object.isRequired
  };

  render() {
    const { collection, workers } = this.props
    return (
      <div className={ styles.container } >
        <Infinite containerHeight={ window.innerHeight } elementHeight={ 18 }>
          { collection.map((item, index) => (
            <TrackItem
              model={ item }
              worker={ workers[item.aid] }
              key={ index } />
          )) }
        </Infinite>
      </div>
    )
  }
}
