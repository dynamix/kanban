module Typus

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    # Return model fields as a OrderedHash
    def model_fields
      hash = ActiveSupport::OrderedHash.new
      columns.map { |u| hash[u.name.to_sym] = u.type.to_sym }
      return hash
    end

    def model_relationships
      hash = ActiveSupport::OrderedHash.new
      reflect_on_all_associations.map { |i| hash[i.name] = i.macro }
      return hash
    end

    ##
    # This method is used to change a Rails behavior.
    #
    #   typus $ script/console
    #   Loading development environment (Rails 2.3.2)
    #   >> TypusUser.human_name
    #   => "Typususer"
    #   >> TypusUser.typus_human_name
    #   => "Typus user"
    #
    def typus_human_name
      human_name(:default => self.name.underscore.humanize)
    end

    def typus_description
      Typus::Configuration.config[self.name]['description']
    end

    # Form and list fields
    def typus_fields_for(filter)

      fields_with_type = ActiveSupport::OrderedHash.new

      begin
        fields = Typus::Configuration.config[name]['fields'][filter.to_s]
        fields = fields.split(', ').collect { |f| f.to_sym }
      rescue
        return [] if filter == 'list'
        filter = 'list'
        retry
      end

      begin

        fields.each do |field|

          attribute_type = model_fields[field]

          # Custom field_type depending on the attribute name.
          case field.to_s
            when 'parent_id' then       attribute_type = :tree
            when /file_name/ then       attribute_type = :file
            when /password/ then        attribute_type = :password
            when 'position' then        attribute_type = :position
          end

          if reflect_on_association(field)
            attribute_type = reflect_on_association(field).macro
          end

          if typus_field_options_for(:selectors).include?(field)
            attribute_type = :selector
          end

          if typus_tiny_mce_fields.include?(field.to_s)
            attribute_type = :tiny_mce
          end

          # And finally insert the field and the attribute_type 
          # into the fields_with_type ordered hash.
          fields_with_type[field.to_s] = attribute_type

        end

      rescue
        fields = Typus::Configuration.config[name]['fields']['list'].split(', ')
        retry
      end

      return fields_with_type

    end

    # Return tiny_mce options of the model merged into the default options
    def typus_tiny_mce_options
      typus_options_for(:tiny_mce).merge(Typus::Configuration.config[name]['fields']['options']['tiny_mce']['options'].symbolize_keys.delete_if { |key,value| value == nil})
    rescue
      typus_options_for(:tiny_mce)
    end

    # Tiny_mce fields of the model
    def typus_tiny_mce_fields
      Typus::Configuration.config[name]['fields']['options']['tiny_mce']['fields'].split(', ')
    rescue
      []
    end

    # Typus sidebar filters.
    def typus_filters

      fields_with_type = ActiveSupport::OrderedHash.new

      data = Typus::Configuration.config[name]['filters']
      return [] unless data
      fields = data.split(', ').collect { |i| i.to_sym }

      fields.each do |field|
        attribute_type = model_fields[field.to_sym]
        if reflect_on_association(field.to_sym)
          attribute_type = reflect_on_association(field.to_sym).macro
        end
        fields_with_type[field.to_s] = attribute_type
      end

      return fields_with_type

    end

    # Extended actions for this model on Typus.
    def typus_actions_for(filter)
      Typus::Configuration.config[name]['actions'][filter.to_s].split(', ')
    rescue
      []
    end

    # Used for +search+, +relationships+
    def typus_defaults_for(filter)
      data = Typus::Configuration.config[name][filter.to_s]
      return (!data.nil?) ? data.split(', ') : []
    end

    def typus_field_options_for(filter)
      Typus::Configuration.config[name]['fields']['options'][filter.to_s].split(', ').collect { |i| i.to_sym }
    rescue
      []
    end

    # We should be able to overwrite options by model.
    def typus_options_for(filter)

      data = Typus::Configuration.config[name]
      unless data['options'].nil?
        value = data['options'][filter.to_s] unless data['options'][filter.to_s].nil?
      end

      return (!value.nil?) ? value : Typus::Configuration.options[filter.to_sym]

    end

    def typus_export_formats
      data = Typus::Configuration.config[name]
      !data['export'].nil? ? data['export'].split(', ') : []
    end

    # Used for `order_by`.
    def typus_order_by

      fields = typus_defaults_for(:order_by)

      order = if fields.empty?
                "#{table_name}.id ASC"
              else
                fields.map do |field|
                  field.include?('-') ? "#{table_name}.#{field.delete('-')} DESC" : "#{table_name}.#{field} ASC"
                end.join(', ')
              end

      return order

    end

    # We are able to define our own booleans.
    def typus_boolean(attribute = :default)

      boolean = Typus::Configuration.config[name]['fields']['options']['booleans'][attribute.to_s] rescue nil
      boolean = 'true, false' if boolean.nil?

      hash = ActiveSupport::OrderedHash.new

      if boolean.kind_of?(Array)
        hash[:true] = boolean.first.humanize
        hash[:false] = boolean.last.humanize
      else
        hash[:true] = boolean.split(', ').first.humanize
        hash[:false] = boolean.split(', ').last.humanize
      end

      return hash

    end

    # We are able to define how to display dates on Typus
    def typus_date_format(attribute = :default)
      date_format = Typus::Configuration.config[name]['fields']['options']['date_formats'][attribute.to_s].to_sym rescue nil
      return !date_format.nil? ? date_format : :db
    end

    # We are able to define which template to use to render the attribute 
    # within the form
    def typus_template(attribute)
      Typus::Configuration.config[name]['fields']['options']['templates'][attribute.to_s] rescue nil
    end

    def build_conditions(params)

      conditions, joins = merge_conditions, []

      query_params = params.dup
      %w( action controller ).each { |param| query_params.delete(param) }

      # If a search is performed.
      if query_params[:search]
        search = typus_defaults_for(:search).map do |s|
                   ["LOWER(#{s}) LIKE '%#{ActiveRecord::Base.connection.quote_string(query_params[:search].downcase)}%'"]
                 end
        conditions = merge_conditions(conditions, search.join(' OR '))
      end

      query_params.each do |key, value|

        filter_type = model_fields[key.to_sym] || model_relationships[key.to_sym]

        ##
        # Sidebar filters:
        #
        # - Booleans: true, false
        # - Datetime: today, last_few_days, last_7_days, last_30_days
        # - Integer & String: *_id and "selectors" (p.ej. category_id)
        #
        # today last_few_days last_7_days last_30_days
        #
        case filter_type
        when :boolean
          condition = { key => (value == 'true') ? true : false }
          conditions = merge_conditions(conditions, condition)
        when :datetime
          interval = case value
                     when 'today' then         Time.new.midnight..Time.new.midnight.tomorrow
                     when 'last_few_days' then 3.days.ago.midnight..Time.new.midnight.tomorrow
                     when 'last_7_days' then   6.days.ago.midnight..Time.new.midnight.tomorrow
                     when 'last_30_days' then  Time.new.midnight.last_month..Time.new.midnight.tomorrow
                     end
          condition = ["#{key} BETWEEN ? AND ?", interval.first.to_s(:db), interval.last.to_s(:db)]
          conditions = merge_conditions(conditions, condition)
        when :integer, :string
          condition = { key => value }
          conditions = merge_conditions(conditions, condition)
        when :has_and_belongs_to_many
          condition = { key => { :id => value } }
          conditions = merge_conditions(conditions, condition)
          joins << key.to_sym
        end

      end

      return conditions, joins

    end

    def typus_user_id?
      columns.map { |u| u.name }.include?(Typus.user_fk)
    end

  end

  module InstanceMethods

    def previous_and_next(condition = {}, klass = self.class)

      previous_conditions = "#{klass.primary_key} < #{quote_value(id)}"
      next_conditions = "#{klass.primary_key} > #{quote_value(id)}"

      if !condition.empty?
        conditions, joins = klass.build_conditions(condition)
        previous_conditions += " AND #{conditions}"
        next_conditions += " AND #{conditions}"
      end

      select = !klass.typus_user_id? ? klass.primary_key : "#{klass.primary_key}, #{Typus.user_fk}"

      previous_ = klass.send(:with_exclusive_scope) do
        klass.find :first,
             :select => select,
             :order => "#{klass.primary_key} DESC",
             :conditions => previous_conditions
      end

      next_ = klass.send(:with_exclusive_scope) do
        klass.find :first,
             :select => select,
             :order => "#{klass.primary_key} ASC",
             :conditions => next_conditions
      end

      return previous_, next_

    end

    def typus_name
      respond_to?(:name) ? name : "#{self.class}##{id}"
    end

    def owned_by?(user)
      send(Typus.user_fk) == user.id
    end

  end

end

ActiveRecord::Base.send :include, Typus
ActiveRecord::Base.send :include, Typus::InstanceMethods