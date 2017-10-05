import * as constants from '../constants'
import axios from 'axios'

//################### SHARES #########################
const requestShares= () =>
  ({
    type: constants.REQUEST_SHARES,
    requestedAt: Date.now()
  })
;

const requestSharesFailure= () => ({type: constants.REQUEST_SHARES_FAILURE});

const receiveShares= json =>
  ({
    type: constants.RECEIVE_SHARES,
    shares: json,
    receivedAt: Date.now()
  })
;

const requestShare= shareId =>
  ({
    type: constants.REQUEST_SHARE,
    shareId,
    requestedAt: Date.now()
  })
;

const requestShareFailure= shareId =>
  ({
    type: constants.REQUEST_SHARE_FAILURE,
    shareId
  })
;

const receiveShare= json =>
  ({
    type: constants.RECEIVE_SHARE,
    share: json
  })
;

const fetchShares= () =>
  function(dispatch) {
    dispatch(requestShares());
    axios.get('shares')
      .then( (response) => {
        return dispatch(receiveShares(response.data));
      })
      .catch( (error) => {
        console.log('fetchShares', error)
        dispatch(requestSharesFailure());
        //return dispatch(app.showErrorDialog({title: 'Could not load shares', message:jqXHR.responseText}));
      });
  }

const shouldFetchShares= function(state) {
  const { shares } = state.shared_filesystem_storage;
  if (shares.isFetching || shares.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchSharesIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchShares(getState())) { return dispatch(fetchShares()); }
  }
;

const canReloadShare= function(state,shareId) {
  const { items } = state.shares;
  let index = -1;
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    if (item.id===shareId) {
      index = i;
      break;
    }
  }
  if (index<0) { return true; }
  return !items[index].isFetching;
};

const reloadShare= shareId =>
  function(dispatch,getState) {
    if (!canReloadShare(getState(),shareId)) { return; }

    dispatch(requestShare(shareId));
    axios.get(`shares/${shareId}`)
      .then((response) => dispatch(receiveShare(response.data)))
      .catch((error) => {
        dispatch(requestShareFailure());
        // return dispatch(app.showErrorDialog({title: 'Could not reload share', message:jqXHR.responseText}));
      }
    )
  }
;

const requestDelete=shareId =>
  ({
    type: constants.REQUEST_DELETE_SHARE,
    shareId
  })
;

const deleteShareFailure=shareId =>
  ({
    type: constants.DELETE_SHARE_FAILURE,
    shareId
  })
;

const removeShare=shareId =>
  ({
    type: constants.DELETE_SHARE_SUCCESS,
    shareId
  })
;

const showDeleteShareDialog=(shareId,message)=>
  function(dispatch){
    dispatch(deleteShareFailure(shareId));
    return dispatch(app.showErrorDialog({title: 'Could not delete share', message}));
  }
;

const deleteShare= shareId =>
  function(dispatch, getState) {
    dispatch(requestDelete(shareId));
    return app.ajaxHelper.delete(`/shares/${shareId}`, {
      success(data, textStatus, jqXHR) {
        if (data && data.errors) {
          return dispatch(showDeleteShareDialog(shareId, ReactFormHelpers.Errors(data)));
        } else {
          dispatch(removeShare(shareId));
          return dispatch(app.removeShareRules(shareId));
        }
      },
      error( jqXHR, textStatus, errorThrown) {
        return dispatch(showDeleteShareDialog(shareId,jqXHR.responseText));
      }
    }
    );
  }
;

const openDeleteShareDialog=function(shareId, options) {
  if (options == null) { options = {}; }
  return function(dispatch, getState) {
    const shareSnapshots = [];
    // check if there are dependent snapshots.
    // Problem: the snapshots may not be loaded yet
    const { snapshots } = getState();
    if (snapshots && snapshots.items) {
      for (let snapshot of Array.from(snapshots.items)) {
        if (snapshot.share_id===shareId) { shareSnapshots.push(snapshot); }
      }
    }

    if (shareSnapshots.length===0) {
      return dispatch(app.showConfirmDialog({
        message: options.message || 'Do you really want to delete this share?' ,
        confirmCallback() { return dispatch(deleteShare(shareId)); }
      }));
    } else {
      return dispatch(app.showInfoDialog({title: 'Existing Dependencies', message: `Please delete dependent snapshots(${shareSnapshots.length}) first!`}));
    }
  };
};

//############### SHARE EXPORT LOCATIONS ################
const requestShareExportLocations= shareId =>
  ({
    type: constants.REQUEST_SHARE_EXPORT_LOCATIONS,
    shareId
  })
;

const receiveShareExportLocations= (shareId, json) =>
  ({
    type: constants.RECEIVE_SHARE_EXPORT_LOCATIONS,
    shareId,
    export_locations: json,
    receivedAt: Date.now()
  })
;

const fetchShareExportLocations= shareId =>
  function(dispatch) {
    dispatch(requestShareExportLocations(shareId));
    axios.get(`shares/${shareId}/export_locations`)
      .then((response) => dispatch(receiveShareExportLocations(shareId,response.data)))
      .catch((error) => {
        console.log('fetchShareExportLocations',error)
        // dispatch(app.showErrorDialog({title: 'Could not load share export locations', message:jqXHR.responseText}));
      }
    );
  }
;

//################ SHARE FORM ###################
const resetShareForm=()=> ({type: constants.RESET_SHARE_FORM});

const shareFormForCreate=()=>
  ({
    type: constants.PREPARE_SHARE_FORM,
    method: 'post',
    action: "shares"
  })
;

const shareFormForUpdate=share =>
  ({
    type: constants.PREPARE_SHARE_FORM,
    data: share,
    method: 'put',
    action: `shares/${share.id}`
  })
;

const shareFormFailure=errors =>
  ({
    type: constants.SHARE_FORM_FAILURE,
    errors
  })
;

const updateShareForm= (name,value) =>
  ({
    type: constants.UPDATE_SHARE_FORM,
    name,
    value
  })
;

const submitShareForm= (successCallback=null) =>
  function(dispatch, getState) {
    const { shared_filesystem_storage: {shareForm} } = getState();
    if (shareForm.isValid) {
      dispatch({type: constants.SUBMIT_SHARE_FORM});
      console.log(shareForm.method,shareForm.action)
      axios[shareForm.method](shareForm.action, { share: shareForm.data })

      .then((response) => {
        if (response.data.errors) {
          return dispatch(shareFormFailure(response.data.errors));
        } else {
          dispatch(receiveShare(response.data));
          dispatch(resetShareForm());
          //dispatch(app.toggleShareNetworkIsNewStatus(data.share_network_id,false));
          if (successCallback) { return successCallback(); }
        }
      })
      .catch((error) => {
        console.log(error)
        //dispatch(app.showErrorDialog({title: 'Could not save share', message:jqXHR.responseText}));
      })
    }
  }
;

//####################### AVAILABILITY ZONES ###########################
// Manila availability zones, not nova!!!
const shouldFetchAvailabilityZones= function(state) {
  const azs = state.shared_filesystem_storage.availabilityZones;
  if (azs.isFetching) {
    return false;
  } else if (azs.receivedAt) {
    return false;
  } else {
    return true;
  }
};
const requestAvailableZones= () => ({type: constants.REQUEST_AVAILABLE_ZONES});

const requestAvailableZonesFailure= () => ({type: constants.REQUEST_AVAILABLE_ZONES_FAILURE});

const receiveAvailableZones= json =>
  ({
    type: constants.RECEIVE_AVAILABLE_ZONES,
    availabilityZones: json,
    receivedAt: Date.now()
  })
;

const fetchAvailabilityZones=() =>
  function(dispatch) {
    dispatch(requestAvailableZones());
    axios.get('shares/availability_zones')
      .then((response) => dispatch(receiveAvailableZones(response.data)))
      .catch((error) => {
        console.log(error)
        dispatch(requestAvailableZonesFailure());
      })
  }
;

const fetchAvailabilityZonesIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchAvailabilityZones(getState())) { return dispatch(fetchAvailabilityZones()); }
  }
;

export {
  fetchShares,
  fetchSharesIfNeeded,
  reloadShare,
  deleteShare,
  fetchShareExportLocations,
  fetchAvailabilityZonesIfNeeded,
  updateShareForm,
  submitShareForm,
  shareFormForCreate,
  shareFormForUpdate
}
