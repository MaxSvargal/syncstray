import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Audio from '../components/Audio'
import * as ApiActions from '../actions/api'
import * as DownloaderActions from '../actions/downloader'
import * as FolderActions from '../actions/folder'

const props = ({ audio, workers }) => ({ audio, workers })
const actions = { ...ApiActions, ...DownloaderActions, ...FolderActions }

export default connect(props, dispatch => bindActionCreators(actions, dispatch))(Audio)
