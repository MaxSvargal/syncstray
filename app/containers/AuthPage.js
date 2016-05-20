import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import Auth from '../components/Auth';
import * as AuthActions from '../actions/auth';

function mapStateToProps(state) {
  return {
    code: state.code
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(AuthActions, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(Auth);
