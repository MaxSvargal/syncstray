import React, { Component, PropTypes } from 'react'

export default class Progress extends Component {
  static propTypes = {
    value: PropTypes.number.isRequired
  };

  render() {
    const val = (this.props.value * 100).toFixed(0)
    return (
      <div>
        <h1
          style={ {
            width: `${val}%`,
            background: 'red',
            transition: 'width .2s' } } >
          { val }%
        </h1>
      </div>
    )
  }
}
