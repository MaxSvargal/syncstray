import { connect } from 'react-redux'
import { selectDlDir } from 'actions'
import selectDir from 'components/selectDir'

export default connect(null, { selectDlDir })(selectDir)
