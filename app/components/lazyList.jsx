import React, { Component } from 'react'

class LazyList extends Component {
  props: {
    children: {}[],
    windowHeight: number,
    elementHeight: number,
    topScrollOffset: number,
    bottomScrollOffset: number,
    onLoad: () => void
  }

  state = {
    showNum: Math.round(this.props.windowHeight / this.props.elementHeight) * 2,
    shownChildren: this.props.children.slice(0, 10),
    scrolledNum: 0,
    topOffset: 0,
    bottomOffset: 0
  }

  componentDidMount() {
    window.addEventListener('scroll', this.scrollListener)
  }

  componentWillReceiveProps(props) {
    const { scrolledNum, showNum } = this.state
    const { children } = this.props

    children.length !== props.children.length &&
      this.setState({ shownChildren: props.children.slice(scrolledNum, scrolledNum + showNum) })
  }

  shouldComponentUpdate(props, state) {
    return this.state.topOffset !== state.topOffset ||
      this.props.children.length !== props.children.length
  }

  componentWillUnmount() {
    window.removeEventListener('scroll', this.scrollListener)
  }

  scrollListener = () => {
    const { showNum } = this.state
    const {
      children, elementHeight, topScrollOffset,
      onLoad, windowHeight, bottomScrollOffset
    } = this.props

    const fullHeight = children.length * elementHeight
    const scrolled = window.scrollY - topScrollOffset
    const scrolledNum = Math.round((scrolled > 0 ? scrolled : 0) / elementHeight)

    const shownChildren = children.slice(scrolledNum, scrolledNum + showNum)
    const topOffset = scrolledNum * elementHeight
    const bottomOffset = fullHeight - (topOffset + (showNum * elementHeight))
    const breakPoint = fullHeight - windowHeight - bottomScrollOffset

    if (this.state.topOffset !== topOffset || this.state.bottomOffset !== bottomOffset) {
      this.setState({ topOffset, bottomOffset, scrolledNum, shownChildren })
      scrolled >= breakPoint && onLoad && onLoad()
    }
  }

  render() {
    const { shownChildren, topOffset, bottomOffset } = this.state
    const styles = this.getStyles()
    return (
      <div style={ styles.root } >
        <div style={ styles.topOffset(topOffset) } />
        <div style={ styles.container }>{ shownChildren }</div>
        <div style={ styles.bottomOffset(bottomOffset) } />
      </div>
    )
  }

  getStyles() {
    return {
      container: {
        display: 'flex',
        flexFlow: 'column nowrap',
        position: 'relative',
        width: '100vw',
        height: '100vh'
      },
      topOffset: value => ({
        marginTop: value
      }),
      bottomOffset: value => ({
        marginBottom: value
      })
    }
  }
}

export default LazyList
