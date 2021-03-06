# frozen_string_literal: true

module ServiceLayerNg
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module Pool
      def pools(filter = {})
        api.dns.list_all_pools(filter).map_to(pools: DnsService::PoolNg)
      end

      def find_pool!(id)
        api.dns.show_a_pool(id).map_to(response_body: DnsService::PoolNg)
      end

      def find_pool(id)
        find_pool!(id)
      rescue => e
        nil
      end
    end
  end
end
