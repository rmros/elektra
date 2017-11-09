# frozen_string_literal: true

class ReactPluginGenerator
  extend Forwardable
  def_delegators :@context, :options, :copy_file, :remove_file, :gsub_file,
                 :create_file, :name, :remove_dir, :directory, :source_paths
  attr_reader :plugin_path

  def initialize(context, plugin_path)
    @context = context
    @plugin_path = plugin_path
  end

  def run
    add_packs
    return unless options.mountable?

    modify_app
    add_routes
    update_assets
  end

  private

  def update_assets
    remove_file "#{plugin_path}/#{name}/app/assets/stylesheets/#{name}/application.css"
    remove_dir "#{plugin_path}/#{name}/app/assets/javascripts"
    copy_file 'react/app/assets/stylesheets/_application.scss', "#{plugin_path}/#{name}/app/assets/stylesheets/#{name}/_application.scss"
  end

  def add_packs
    directory 'react/app/javascript', "#{plugin_path}/#{name}/app/javascript"
  end

  def modify_app
    remove_dir "#{plugin_path}/#{name}/app/controllers"
    directory 'react/app/controllers', "#{plugin_path}/#{name}/app/controllers/#{name}"
    remove_dir "#{plugin_path}/#{name}/app/views"
  end

  def add_routes
    remove_file "#{plugin_path}/#{name}/config/routes.rb"
    copy_file 'react/config/routes.rb', "#{plugin_path}/#{name}/config/routes.rb"
  end
end
