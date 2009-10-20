module Admin::FormHelper

  def build_form(fields)

    options = { :start_year => @resource[:class].typus_options_for(:start_year), 
                :end_year => @resource[:class].typus_options_for(:end_year), 
                :minute_step => @resource[:class].typus_options_for(:minute_step) }

    returning(String.new) do |html|

      html << (error_messages_for :item, :header_tag => 'h3')
      html << '<ul>'

      fields.each do |key, value|

        if template = @resource[:class].typus_template(key)
          html << typus_template_field(key, template, options)
          next
        end

        html << case value
                when :belongs_to  then typus_belongs_to_field(key)
                when :tree        then typus_tree_field(key)
                when :boolean, :date, :datetime, :file, :password, :selector, :string, :text, :time, :tiny_mce
                  typus_template_field(key, value.to_s, options)
                else
                  typus_template_field(key, 'string', options)
                end
      end

      html << '</ul>'

    end

  end

  def typus_belongs_to_field(attribute)

    ##
    # We only can pass parameters to 'new' and 'edit', so this hack makes
    # the work to replace the current action.
    #
    params[:action] = (params[:action] == 'create') ? 'new' : params[:action]

    back_to = '/' + [ params[:controller], params[:action], params[:id] ].compact.join('/')

    related = @resource[:class].reflect_on_association(attribute.to_sym).class_name.constantize
    related_fk = @resource[:class].reflect_on_association(attribute.to_sym).primary_key_name

    message = [ _("Are you sure you want to leave this page?"),
                _("If you have made any changes to the fields without clicking the Save/Update entry button, your changes will be lost."), 
                _("Click OK to continue, or click Cancel to stay on this page.") ]

    returning(String.new) do |html|

      if related.respond_to?(:roots)
        html << typus_tree_field(related_fk, related.roots, related_fk)
      else
        html << <<-HTML
<li><label for="item_#{attribute}">#{@resource[:class].human_attribute_name(attribute)}
    <small>#{link_to _("Add"), { :controller => "admin/#{related.class_name.tableize}", :action => 'new', :back_to => back_to, :selected => related_fk }, :confirm => message.join("\n\n") if @current_user.can_perform?(related, 'create')}</small>
    </label>
#{select :item, related_fk, related.find(:all, :order => related.typus_order_by).collect { |p| [p.typus_name, p.id] }, { :include_blank => true }, { :disabled => attribute_disabled?(attribute) } }</li>
        HTML
      end

    end

  end

  def typus_tree_field(attribute, items = @resource[:class].roots, attribute_virtual = 'parent_id')
    <<-HTML
<li><label for="item_#{attribute}">#{@resource[:class].human_attribute_name(attribute)}</label>
<select id="item_#{attribute}" #{'disabled="disabled"' if attribute_disabled?(attribute)} name="item[#{attribute}]">
  <option value=""></option>
  #{expand_tree_into_select_field(items, attribute_virtual)}
</select></li>
    HTML
  end

  def typus_relationships

    @back_to = '/' + [ params[:controller], params[:action], params[:id] ].compact.join('/')

    returning(String.new) do |html|
      @resource[:class].typus_defaults_for(:relationships).each do |relationship|

        association = @resource[:class].reflect_on_association(relationship.to_sym)

        next if !@current_user.can_perform?(association.class_name.constantize, 'read')

        case association.macro
        when :has_and_belongs_to_many
          html << typus_form_has_and_belongs_to_many(relationship)
        when :has_many
          html << typus_form_has_many(relationship)
        when :has_one
          html << typus_form_has_one(relationship)
        end

      end
    end

  end

  def typus_form_has_many(field)
    returning(String.new) do |html|

      model_to_relate = @resource[:class].reflect_on_association(field.to_sym).class_name.constantize
      model_to_relate_as_resource = model_to_relate.name.tableize

      reflection = @resource[:class].reflect_on_association(field.to_sym)
      association = reflection.macro
      foreign_key = reflection.through_reflection ? reflection.primary_key_name.pluralize : reflection.primary_key_name

      link_options = { :controller => "admin/#{model_to_relate_as_resource.pluralize}", 
                       :action => 'new', 
                       :back_to => "#{@back_to}##{field}", 
                       :resource => @resource[:self].singularize, 
                       :resource_id => @item.id, 
                       foreign_key => @item.id }

      condition = if @resource[:class].typus_user_id? && !@current_user.is_root?
                    @item.owned_by?(@current_user)
                  else
                    true
                  end

      if condition
        add_new = <<-HTML
  <small>#{link_to _("Add new"), link_options if @current_user.can_perform?(model_to_relate, 'create')}</small>
        HTML
      end

      html << <<-HTML
<a name="#{field}"></a>
<div class="box_relationships" id="#{model_to_relate_as_resource}">
  <h2>
  #{link_to model_to_relate.typus_human_name.pluralize, { :controller => "admin/#{model_to_relate_as_resource}", foreign_key => @item.id }, :title => _("{{model}} filtered by {{filtered_by}}", :model => model_to_relate.typus_human_name.pluralize, :filtered_by => @item.typus_name)}
  #{add_new}
  </h2>
      HTML

      ##
      # It's a has_many relationship, so items that are already assigned to another
      # entry are assigned to that entry.
      #
      items_to_relate = model_to_relate.find(:all, :conditions => ["#{foreign_key} is ?", nil])
      if condition && !items_to_relate.empty?
        html << <<-HTML
  #{form_tag :action => 'relate', :id => @item.id}
  #{hidden_field :related, :model, :value => model_to_relate}
  <p>#{select :related, :id, items_to_relate.collect { |f| [f.typus_name, f.id] }.sort_by { |e| e.first } } &nbsp; #{submit_tag _("Add"), :class => 'button'}</p>
  </form>
        HTML
      end

      conditions = if model_to_relate.typus_options_for(:only_user_items) && !@current_user.is_root?
                    { Typus.user_fk => @current_user }
                  end

      options = { :order => model_to_relate.typus_order_by, :conditions => conditions }
      items_count = @resource[:class].find(params[:id]).send(field).count(:conditions => conditions)
      items_per_page = model_to_relate.typus_options_for(:per_page).to_i

      @pager = ::Paginator.new(items_count, items_per_page) do |offset, per_page|
        options.merge!({:limit => per_page, :offset => offset})
        items = @resource[:class].find(params[:id]).send(field).find(:all, options)
      end

      @items = @pager.page(params[:page])

      unless @items.empty?
        options = { :back_to => "#{@back_to}##{field}", :resource => @resource[:self], :resource_id => @item.id }
        html << build_list(model_to_relate, 
                           model_to_relate.typus_fields_for(:relationship), 
                           @items, 
                           model_to_relate_as_resource, 
                           options, 
                           association)
        html << pagination(:anchor => model_to_relate.name.tableize) unless pagination.nil?
      else
        html << <<-HTML
  <div id="flash" class="notice"><p>#{_("There are no {{records}}.", :records => model_to_relate.typus_human_name.pluralize.downcase)}</p></div>
        HTML
      end
      html << <<-HTML
</div>
      HTML
    end
  end

  def typus_form_has_and_belongs_to_many(field)
    returning(String.new) do |html|

      model_to_relate = @resource[:class].reflect_on_association(field.to_sym).class_name.constantize
      model_to_relate_as_resource = model_to_relate.name.tableize

      reflection = @resource[:class].reflect_on_association(field.to_sym)
      association = reflection.macro

      condition = if @resource[:class].typus_user_id? && !@current_user.is_root?
                    @item.owned_by?(@current_user)
                  else
                    true
                  end

      if condition
        add_new = <<-HTML
  <small>#{link_to _("Add new"), :controller => field, :action => 'new', :back_to => @back_to, :resource => @resource[:self], :resource_id => @item.id if @current_user.can_perform?(model_to_relate, 'create')}</small>
        HTML
      end

      html << <<-HTML
<a name="#{field}"></a>
<div class="box_relationships" id="#{model_to_relate_as_resource}">
  <h2>
  #{link_to model_to_relate.typus_human_name.pluralize, :controller => "admin/#{model_to_relate_as_resource}"}
  #{add_new}
  </h2>
      HTML

      items_to_relate = (model_to_relate.find(:all) - @item.send(field))

      if condition && !items_to_relate.empty?
        html << <<-HTML
  #{form_tag :action => 'relate', :id => @item.id}
  #{hidden_field :related, :model, :value => model_to_relate}
  <p>#{select :related, :id, items_to_relate.collect { |f| [f.typus_name, f.id] }.sort_by { |e| e.first } } &nbsp; #{submit_tag _("Add"), :class => 'button'}</p>
  </form>
        HTML
      end

      items = @resource[:class].find(params[:id]).send(field)
      unless items.empty?
        html << build_list(model_to_relate, 
                           model_to_relate.typus_fields_for(:relationship), 
                           items, 
                           model_to_relate_as_resource, 
                           {}, 
                           association)
      else
        html << <<-HTML
  <div id="flash" class="notice"><p>#{_("There are no {{records}}.", :records => model_to_relate.typus_human_name.pluralize.downcase)}</p></div>
        HTML
      end
      html << <<-HTML
</div>
      HTML
    end
  end

  def typus_form_has_one(field)
    returning(String.new) do |html|

      model_to_relate = @resource[:class].reflect_on_association(field.to_sym).class_name.constantize
      model_to_relate_as_resource = model_to_relate.name.tableize

      reflection = @resource[:class].reflect_on_association(field.to_sym)
      association = reflection.macro

      html << <<-HTML
<a name="#{field}"></a>
<div class="box_relationships">
  <h2>
  #{link_to model_to_relate.typus_human_name, :controller => "admin/#{model_to_relate_as_resource}"}
  </h2>
      HTML
      items = Array.new
      items << @resource[:class].find(params[:id]).send(field) unless @resource[:class].find(params[:id]).send(field).nil?
      unless items.empty?
        options = { :back_to => @back_to, :resource => @resource[:self], :resource_id => @item.id }
        html << build_list(model_to_relate, 
                           model_to_relate.typus_fields_for(:relationship), 
                           items, 
                           model_to_relate_as_resource, 
                           options, 
                           association)
      else
        html << <<-HTML
  <div id="flash" class="notice"><p>#{_("There is no {{records}}.", :records => model_to_relate.typus_human_name.downcase)}</p></div>
        HTML
      end
      html << <<-HTML
</div>
      HTML
    end
  end

  def typus_template_field(attribute, template, options = {})
    template_name = File.join('admin', 'templates', template)
    render :partial => template_name, 
           :locals => { :resource => @resource, :attribute => attribute, :options => options }
  end

  def attribute_disabled?(attribute)
    accessible = @resource[:class].accessible_attributes
    return accessible.nil? ? false : !accessible.include?(attribute)
  end

  ##
  # Tree builder when model +acts_as_tree+
  #
  def expand_tree_into_select_field(items, attribute)
    returning(String.new) do |html|
      items.each do |item|
        html << %{<option #{"selected" if @item.send(attribute) == item.id} value="#{item.id}">#{"&nbsp;" * item.ancestors.size * 8} &#92;_ #{item.typus_name}</option>\n}
        html << expand_tree_into_select_field(item.children, attribute) unless item.children.empty?
      end
    end
  end

end