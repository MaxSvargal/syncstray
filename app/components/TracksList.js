import React, { Component } from 'react'
import radium from 'radium'
import Infinite from 'react-infinite'
import TweenLite from 'gsap'
import TrackItem from './TrackItem'

let scrolled = 0

@radium
export default class TracksList extends Component {
  props: {
    collection: [],
    dlState: bool
  }

  onTrackDownload = () => {
    const { container: { refs: { scrollable, topSpacer } } } = this.refs
    scrolled += 42
    TweenLite.to(scrollable, 1, {
      scrollTop: scrolled + (42 * 6) - topSpacer.style.height
    })
  }

  render() {
    const { collection, dlState } = this.props
    const styles = this.getStyles()

    return (
      <div
        style={ [
          styles.container,
          !dlState && styles.grayscale] } >
        <Infinite
          containerHeight={ window.innerHeight }
          elementHeight={ 42 }
          ref="container" >
          { collection.map((item, index) => (
            <TrackItem
              key={ index }
              model={ item }
              onDownloadEnd={ this.onTrackDownload } />
          )) }
        </Infinite>
      </div>
    )
  }

  getStyles() {
    return {
      container: {
        background: '#262d35'
      },
      grayscale: {
        filter: 'grayscale(.8)'
      }
    }
  }
}
