import React, { Component } from 'react'
import { remote } from 'electron'

const { app, dialog } = remote

export default class SelectDir extends Component {
  props: {
    selectDlDir: () => void
  }

  componentDidMount() {
    const selectFolder = () => {
      const options = {
        properties: [ 'openDirectory' ],
        title: 'Please, choose directory for download',
        defaultPath: app.getPath('music')
      }
      dialog.showOpenDialog(options, values =>
        (values ? this.props.selectDlDir(values[0]) : selectFolder()))
    }
    selectFolder()
  }

  render() {
    const styles = this.getStyles()

    return (
      <div style={ styles.root }>
        <h1>At now, select download directory.</h1>
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
      }
    }
  }
}
