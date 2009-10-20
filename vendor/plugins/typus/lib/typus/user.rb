module Typus

  module EnableAsTypusUser

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def enable_as_typus_user

        extend ClassMethodsMixin

        attr_accessor :password
        attr_protected :status

        validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
        validates_presence_of :email
        validates_uniqueness_of :email

        validates_confirmation_of :password, :if => :password_required?
        validates_length_of :password, :within => 8..40, :if => :password_required?
        validates_presence_of :password, :if => :password_required?

        validates_presence_of :role

        before_save :initialize_salt, :encrypt_password, :initialize_token
        before_save :set_preferences

        serialize :preferences

        include InstanceMethods

      end

    end

    module ClassMethodsMixin

      def role
        Typus::Configuration.roles.keys.sort
      end

      def language
        Typus.locales
      end

      def authenticate(email, password)
        user = find_by_email_and_status(email, true)
        user && user.authenticated?(password) ? user : nil
      end

      def generate(*args)
        options = args.extract_options!
        new :email => options[:email], 
            :password => options[:password], 
            :password_confirmation => options[:password], 
            :role => options[:role]
      end

    end

    module InstanceMethods

      def name
        (!first_name.empty? && !last_name.empty?) ? "#{first_name} #{last_name}" : email
      end

     def authenticated?(password)
        crypted_password == encrypt(password)
      end

      def resources
        Typus::Configuration.roles[role].compact
      end

      def can_perform?(resource, action, options = {})

        return false if !resources.include?(resource.to_s)

        _action = if options[:special]
                    action
                  else
                    case action
                    when 'new', 'create'       then 'create'
                    when 'index', 'show'       then 'read'
                    when 'edit', 'update'      then 'update'
                    when 'position', 'toggle'  then 'update'
                    when 'relate', 'unrelate'  then 'update'
                    when 'destroy'             then 'delete'
                    else action
                    end
                  end

        resources[resource.to_s].split(', ').include?(_action)

      end

      def is_root?
        role == Typus::Configuration.options[:root]
      end

    protected

      def language
        preferences[:locale] rescue Typus::Configuration.options[:default_locale]
      end

      def language=(locale)
        self.preferences = { :locale => locale }
      end

      def set_preferences
        if self.preferences.nil? || self.preferences[:locale].nil? || self.preferences[:locale].blank?
          self.preferences = { :locale => Typus::Configuration.options[:default_locale] }
        end
      end

      def generate_hash(string)
        Digest::SHA1.hexdigest(string)
      end

      def encrypt_password
        return if password.blank?
        self.crypted_password = encrypt(password)
      end

      def encrypt(string)
        generate_hash("--#{salt}--#{string}")
      end

      def initialize_salt
        self.salt = generate_hash("--#{Time.now.utc.to_s}--#{email}--") if new_record?
      end

      def initialize_token
        generate_token if new_record?
      end

      def generate_token
        self.token = encrypt("--#{Time.now.utc.to_s}--#{password}--").first(12)
      end

      def password_required?
        crypted_password.blank? || !password.blank?
      end

    end

  end

end

ActiveRecord::Base.send :include, Typus::EnableAsTypusUser