import React, { Component } from 'react'
import Infinite from 'react-infinite'
import TrackItem from './TrackItem'
import styles from './TracksList.css'

export default class TracksList extends Component {
  props: {
    collection: [],
    workers: {}
  };

  onTrackDownload = () => {
    console.log('FFFUUUUUUU')
    const { container } = this.refs
    const scrolled = container.utils.getScrollTop()
    container.utils.setScrollTop(scrolled + 42)
  }

  render() {
    const { collection, workers } = this.props
    return (
      <div className={ styles.container }>
        <Infinite
          containerHeight={ window.innerHeight }
          elementHeight={ 42 }
          ref="container" >
          { collection.map((item, index) => (
            <TrackItem
              model={ item }
              worker={ workers[item.aid] }
              onDownloadEnd={ this.onTrackDownload }
              key={ index } />
          )) }
        </Infinite>
      </div>
    )
  }
}
