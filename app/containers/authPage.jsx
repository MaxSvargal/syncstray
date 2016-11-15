import { connect } from 'react-redux'
import { setVkAuthCode } from 'actions'
import Auth from 'components/auth'

export default connect(null, { setVkAuthCode })(Auth)
