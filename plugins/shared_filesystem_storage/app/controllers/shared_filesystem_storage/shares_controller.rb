# frozen_string_literal: true

module SharedFilesystemStorage
  # shares
  class SharesController < ApplicationController
    def index
      render json: services.shared_filesystem_storage.shares_detail
    end

    def export_locations
      render json: services.shared_filesystem_storage
                           .share_export_locations(params[:id])
    end

    def show
      render json: services.shared_filesystem_storage.find_share(params[:id])
    end

    def availability_zones
      render json: services.shared_filesystem_storage.availability_zones
    end

    def update
      share = services.shared_filesystem_storage.new_share(share_params)
      share.id = params[:id]

      if share.save
        render json: share
      else
        render json: { errors: share.errors }
      end
    end

    def create
      share = services.shared_filesystem_storage.new_share(share_params)
      share.share_type ||= 'default'

      if share.save
        render json: share
      else
        render json: { errors: share.errors }
      end
    end

    def destroy
      share = services.shared_filesystem_storage.new_share
      share.id = params[:id]

      if share.destroy
        head :no_content
      else
        render json: { errors: share.errors }
      end
    end

    protected

    def share_params
      params.require(:share).permit(
        :share_proto,
        :size,
        :name,
        :description,
        :display_name,
        :display_description,
        :share_type,
        :volume_type,
        :snapshot_id,
        :metadata,
        :share_network_id,
        :consistency_group_id,
        :availability_zone
      )
    end
  end
end
