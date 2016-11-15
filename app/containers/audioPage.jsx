import { connect } from 'react-redux'
import { replace } from 'react-router-redux'
import { togglePauseDownload, setDlProgress } from 'actions'
import Audio from 'components/audio'

const mapStateToProps = ({ vk: { token, tracks } }) => ({ token, tracks })

export default connect(mapStateToProps, { togglePauseDownload, setDlProgress, replace })(Audio)
