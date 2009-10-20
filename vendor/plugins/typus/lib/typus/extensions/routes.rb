if defined?(ActionController::Routing::RouteSet)

  class ActionController::Routing::RouteSet

    def load_routes_with_typus!
      typus_routes = File.join(File.dirname(__FILE__), 'routes_hack.rb')
      add_configuration_file(typus_routes) unless configuration_files.include?(typus_routes)
      load_routes_without_typus!
    end

    alias_method_chain :load_routes!, :typus

  end

end