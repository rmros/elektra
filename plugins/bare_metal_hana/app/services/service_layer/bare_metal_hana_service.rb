module ServiceLayer

  class BareMetalHanaService < Core::ServiceLayer::Service

    def driver
      @driver ||= BareMetalHana::Driver::MyDriver.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end
    
    def available?(action_name_sym=nil)
      return !current_user.service_url('baremetal').blank?
    end
    

    def test
      driver.test
    end
  end
end