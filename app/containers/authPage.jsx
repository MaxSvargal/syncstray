import { connect } from 'react-redux'
import { setVkAuthCode } from 'actions'
import { replace } from 'react-router-redux'
import Auth from 'components/auth'

export default connect(null, { setVkAuthCode, replace })(Auth)
