#= require components/form_helpers


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateClusterForm, addNodePool, deleteNodePool, updateNodePoolForm, submitClusterForm } = kubernetes


NewCluster = ({
  close,
  clusterForm,
  handleSubmit,
  handleChange,
  handleNodePoolChange,
  handleNodePoolAdd,
  handleNodePoolRemove


}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)


  cluster = clusterForm.data
  div null,
    div className: 'modal-body',
      if clusterForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: clusterForm.errors

      form className: 'form form-horizontal',
        # Name
        div className: "form-group required string  cluster_name" ,
          label className: "string required col-sm-4 control-label", htmlFor: "name",
            abbr title: "required", '*'
            ' Cluster Name'
          div className: "col-sm-8",
            div className: "input-wrapper",
              input
                className: "string required form-control",
                type: "text",
                name: "name",
                placeholder: "lower case letters and numbers",
                value: cluster.name || '',
                onChange: onChange


      div className: 'toolbar toolbar-controlcenter',
        h4 null, "Nodepools"
        div className: 'main-control-buttons',
          button className: 'btn btn-primary', onClick: ((e) => e.preventDefault(); handleNodePoolAdd()),
            'Add Pool'

      for nodePool, i in cluster.spec.nodePools

        div className: 'nodepool-form', key: "nodepool-#{i}",
          form className: 'form form-inline form-inline-flex',
            h5 className: 'title', "Pool #{i+1}:"

            # Nodepool name
            div className: "form-group required string" ,
              label className: "string required control-label", htmlFor: "name",
                'Name '
                abbr title: "required", '*'

              input
                className: "string form-control",
                "data-index": i,
                type: "text",
                name: "name",
                placeholder: "lower case letters and numbers",
                value: nodePool.name || '',
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value))

            # Nodepool size
            div className: "form-group" ,
              label className: "string control-label", htmlFor: "size",
                'Size '
                abbr title: "required", '*'

              input
                className: "form-control",
                "data-index": i,
                type: "number",
                name: "size",
                placeholder: "Number of nodes",
                value: (if isNaN(nodePool.size) then '' else nodePool.size),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, parseInt(e.target.value, 10)))

            # Nodepool flavor
            div className: "form-group string" ,
              label className: "string control-label", htmlFor: "flavor",
                'Flavor '
                abbr title: "required", '*'

              select
                name: "flavor",
                "data-index": i,
                className: "select required form-control",
                value: (nodePool.flavor || ''),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                  option value: '', 'Choose flavor'
                  option value: 'm1.small', 'm1.small'
                  option value: 'm1.medium', 'm1.medium'
                  option value: 'm1.xmedium', 'm1.xmedium'
                  option value: 'm1.large', 'm1.large'
                  option value: 'm1.xlarge', 'm1.xlarge'


            button
              className: 'btn btn-default',
              "data-index": i,
              disabled: 'disabled' unless nodePool.new,
              onClick: ((e) => e.preventDefault(); handleNodePoolRemove(e.currentTarget.dataset.index)),
                span className: "fa #{if nodePool.new then 'fa-trash' else 'fa-lock'}"



#       <option value="88813ab0-8f42-4d36-add1-9322187f2f56">baremetal  (RAM: 16 MiB, VCPUs: 1, Disk: 100 GiB )</option>
# <option value="10">m1.tiny  (RAM: 512 MiB, VCPUs: 1, Disk: 1 GiB )</option>
# <option value="20">m1.small  (RAM: 2 GiB, VCPUs: 2, Disk: 16 GiB )</option>
# <option value="22">m1.xsmall  (RAM: 4 GiB, VCPUs: 2, Disk: 64 GiB )</option>
# <option value="30">m1.medium  (RAM: 4 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="32">m1.xmedium  (RAM: 8 GiB, VCPUs: 2, Disk: 64 GiB )</option>
# <option value="40">m1.large  (RAM: 8 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="50">m1.xlarge  (RAM: 16 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="110">m2.xlarge  (RAM: 16 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="120">m2.2xlarge  (RAM: 24 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="60">m1.2xlarge  (RAM: 32 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="130">m2.3xlarge  (RAM: 48 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="100">m2.large  (RAM: 64 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="140">m2.4xlarge  (RAM: 64 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="70">m1.4xlarge  (RAM: 64 GiB, VCPUs: 16, Disk: 64 GiB )</option>
# <option value="90">x1.memory  (RAM: 128 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="80">m1.10xlarge  (RAM: 160 GiB, VCPUs: 40, Disk: 64 GiB )</option>
# <option value="99">x1.2xmemory  (RAM: 256 GiB, VCPUs: 16, Disk: 64 GiB )</option>
# <option value="150">x1.4xmemory  (RAM: 512 GiB, VCPUs: 32, Disk: 64 GiB )</option>



    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Create',
        loading: clusterForm.isSubmitting,
        disabled: !clusterForm.isValid
        onSubmit: (() -> handleSubmit(close))

NewCluster = connect(
  (state) ->
    clusterForm: state.clusterForm

  (dispatch) ->
    handleChange:         (name, value)         -> dispatch(updateClusterForm(name, value))
    handleNodePoolChange: (index, name, value)  -> dispatch(updateNodePoolForm(index, name, value))
    handleNodePoolAdd:    ()                    -> dispatch(addNodePool())
    handleNodePoolRemove: (index)               -> dispatch(deleteNodePool(index))
    handleSubmit:         (callback)            -> dispatch(submitClusterForm(callback))

)(NewCluster)

kubernetes.NewClusterModal = ReactModal.Wrapper('Create Cluster', NewCluster,
  large: true,
  closeButton: false,
  static: true
)
