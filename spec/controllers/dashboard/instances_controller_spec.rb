require 'spec_helper'
require 'controllers/dashboard/shared_examples'

describe Dashboard::InstancesController do
  include AuthenticationStub
  
  it_behaves_like "an dashboard controller"
  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_id])
    @project = create(:project, key: default_params[:project_id], domain: @domain)
  end


  before(:each) do
    stub_authentication  

    driver = object_spy('driver')
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:new_user?).and_return(false)
    allow_any_instance_of(Openstack::IdentityService).to receive(:driver).and_return(driver)    
    allow_any_instance_of(Openstack::ComputeService).to receive(:driver).and_return(driver)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_success
    end
  end

end