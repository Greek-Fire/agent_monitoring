module AgentMonitoring
  class Engine < ::Rails::Engine
    isolate_namespace AgentMonitoring
    engine_name 'agent_monitoring'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer 'agent_monitoring.load_app_instance_data' do |app|
      AgentMonitoring::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'agent_monitoring.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :agent_monitoring do
        requires_foreman '>= 3.7.0'
        register_gettext

        # Add Global files for extending foreman-core components and routes
        register_global_js_file 'global'

        # Add permissions
        security_block :agent_monitoring do
          permission :view_agent_monitoring, { :'agent_monitoring/example' => [:new_action],
                                                      :'react' => [:index] }
        end

        # Add a new role called 'Discovery' if it doesn't exist
        role 'AgentMonitoring', [:view_agent_monitoring]

        # add menu entry
        #sub_menu :top_menu, :plugin_template, icon: 'pficon pficon-enterprise', caption: N_('Hallas Automation'), after: :hosts_menu do
        #  menu :top_menu, :welcome, caption: N_('Agents Monitoring'), engine: AgentMonitoring::Engine
        #  menu :top_menu, :new_action, caption: N_('Agents'), engine: AgentMonitoring::Engine
        #end

        sub_menu :top_menu, :example, :caption=> N_('Example'), :after=> :hosts_menu do
          menu :top_menu, :level1, :caption=>N_('the first level'), :url_hash => {:controller=> :example, :action=>:index}
          menu :top_menu, :level2, :url_hash => {:controller=> :example, :action=>:index}
          menu :top_menu, :level3, :url_hash => {:controller=> :example, :action=>:index}
          sub_menu :top_menu, :inner_level, :caption=> N_('Inner level') do
            menu :top_menu, :level41, :url_hash => {:controller=> :example, :action=>:index}
            menu :top_menu, :level42, :url_hash => {:controller=> :example, :action=>:index}
          end
          menu :top_menu, :level5, :url_hash => {:controller=> :example, :action=>:index}
        end
       

        # add dashboard widget
        widget 'agent_monitoring_widget', name: N_('Foreman plugin template widget'), sizex: 4, sizey: 1
      end
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do

      begin
        Host::Managed.send(:include, AgentMonitoring::HostExtensions)
        HostsHelper.send(:include, AgentMonitoring::HostsHelperExtensions)
      rescue => e
        Rails.logger.warn "AgentMonitoring: skipping engine hook (#{e})"
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        AgentMonitoring::Engine.load_seed
      end
    end
  end
end
