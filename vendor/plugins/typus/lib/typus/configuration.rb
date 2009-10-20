module Typus

  module Configuration

    # Default options which can be overwritten from the initializer.
    typus_options = { :app_name => 'Typus', 
                      :config_folder => 'config/typus', 
                      :default_locale => :en, 
                      :email => 'admin@example.com', 
                      :file_preview => :typus_preview, 
                      :file_thumbnail => :typus_thumbnail, 
                      :recover_password => false, 
                      :relationship => 'typus_users', 
                      :root => 'admin', 
                      :ssl => false, 
                      :user_class_name => 'TypusUser', 
                      :user_fk => 'typus_user_id' }

    # Default options which can be overwritten from the initializer.
    model_options = { :default_action_on_item => 'edit', 
                      :end_year => nil,
                      :form_rows => 15, 
                      :index_after_save => false, 
                      :minute_step => 5, 
                      :nil => 'nil', 
                      :on_header => false, 
                      :only_user_items => false, 
                      :per_page => 15, 
                      :sidebar_selector => 5, 
                      :start_year => nil, 
                      :tiny_mce => { :theme => 'advanced',
                                     :theme_advanced_toolbar_location => 'top',
                                     :theme_advanced_toolbar_align => 'left' }, 
                      :toggle => true }

    @@options = typus_options.merge(model_options)

    mattr_accessor :options

    # Read Typus Configuration files placed on <tt>config/typus/**/*.yml</tt>.
    def self.config!

      files = Dir["#{Rails.root}/#{options[:config_folder]}/**/*.yml"].sort
      files = files.delete_if { |x| x.include?('_roles.yml') }

      @@config = {}
      files.each do |file|
        data = YAML.load_file(file)
        @@config = @@config.merge(data) if data
      end

      return @@config

    end

    mattr_accessor :config

    # Read Typus Roles from configuration files placed on <tt>config/typus/**/*_roles.yml</tt>.
    def self.roles!

      files = Dir["#{Rails.root}/#{options[:config_folder]}/**/*_roles.yml"].sort

      @@roles = { options[:root] => {} }

      files.each do |file|
        data = YAML.load_file(file)
        next unless data
        data.each do |key, value|
          next unless value
          begin
            @@roles[key] = @@roles[key].merge(value)
          rescue
            @@roles[key] = value
          end
        end
      end

      return @@roles.compact

    end

    mattr_accessor :roles

  end

end