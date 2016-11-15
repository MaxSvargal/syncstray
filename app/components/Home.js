// @flow
import React, { Component } from 'react'
import { Link } from 'react-router'


export default class Home extends Component {
  render() {
    const styles = this.getStyles()

    return (
      <div style={ styles.root }>
        <h1>Welcome!</h1>
        <div>
          <Link to='/auth' style={ styles.link }>Log in</Link>
        </div>
      </div>
    )
  }

  getStyles() {
    return {
      root: {
        width: '100vw',
        height: '100vh',
        display: 'flex',
        flexFlow: 'column wrap',
        alignItems: 'center',
        justifyContent: 'center'
      },
      link: {
        display: 'block',
        background: 'black',
        padding: '1rem 3rem',
        color: 'white',
        textDecoration: 'none'
      }
    }
  }
}
