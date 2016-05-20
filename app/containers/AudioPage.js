import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Audio from '../components/Audio'
import * as ApiActions from '../actions/api'
import * as DownloaderActions from '../actions/downloader'

export default connect(({ audio, workers }) => ({ audio, workers }), dispatch =>
  bindActionCreators({ ...ApiActions, ...DownloaderActions }, dispatch)
)(Audio)
