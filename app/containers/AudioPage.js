import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Audio from '../components/Audio'
import * as ApiActions from '../actions/api'
import * as DownloaderActions from '../actions/downloader'
import * as FolderActions from '../actions/folder'
import * as TrackActions from '../actions/trackState'

const props = ({ audio, workers, dlState, progresStates }) =>
  ({ audio, workers, dlState, progresStates })
const actions = { ...ApiActions, ...DownloaderActions, ...FolderActions, ...TrackActions }

export default connect(props, dispatch => bindActionCreators(actions, dispatch))(Audio)
