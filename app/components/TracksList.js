import React, { Component, PropTypes } from 'react'
import Infinite from 'react-infinite'
import TrackItem from './TrackItem'

export default class TracksList extends Component {
  static propTypes = {
    collection: PropTypes.array.isRequired,
    workers: PropTypes.object.isRequired
  };

  render() {
    const { collection, workers } = this.props
    return (
      <Infinite containerHeight={ 400 } elementHeight={ 18 }>
        { collection.map((item, index) => (
          <TrackItem
            model={ item }
            worker={ workers[item.aid] }
            key={ index } />
        )) }
      </Infinite>
    )
  }
}
