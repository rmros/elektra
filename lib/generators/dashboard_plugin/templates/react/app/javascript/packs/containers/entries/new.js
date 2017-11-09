import { connect } from  'react-redux';
import NewEntryModal from '../../components/entries/new';
import { submitNewEntryForm } from '../../actions/entries'

export default connect(
  ({%{PLUGIN_NAME}: state},ownProps ) => ({}),
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewEntryForm(values))
  })
)(NewEntryModal);
