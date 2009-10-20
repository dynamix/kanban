module Admin::SidebarHelper

  def build_typus_list(items, *args)

    options = args.extract_options!

    header = if options[:header]
               _(options[:header].humanize)
             elsif options[:attribute]
               @resource[:class].human_attribute_name(options[:attribute])
             end

    return String.new if items.empty?
    returning(String.new) do |html|
      html << "<h2>#{header}</h2>\n" unless header.nil?
      next unless options[:selector].nil?
      html << "<ul>\n"
      items.each do |item|
        html << "<li>#{item}</li>\n"
      end
      html << "</ul>\n"
    end

  end

  def actions

    items = []

    case params[:action]
    when 'index', 'edit', 'show', 'update'
      if @current_user.can_perform?(@resource[:class], 'create')
        items << (link_to _("Add entry"), :action => 'new')
      end
    end

    case params[:action]
    when 'show'
      condition = if @resource[:class].typus_user_id? && !@current_user.is_root?
                    @item.owned_by?(@current_user)
                  else
                    @current_user.can_perform?(@resource[:class], 'destroy')
                  end
      items << (link_to _("Edit entry"), :action => 'edit', :id => @item.id) if condition
    end

    @resource[:class].typus_actions_for(params[:action]).each do |action|
      if @current_user.can_perform?(@resource[:class], action)
        items << (link_to _(action.humanize), params.merge(:action => action))
      end
    end

    if %w( new create edit show update ).include?(params[:action])
      items << (link_to _("Back to list"), :action => 'index')
    end

    build_typus_list(items, :header => 'actions')

  end

  def export
    formats = []
    @resource[:class].typus_export_formats.each do |f|
      formats << (link_to f.upcase, params.merge(:format => f))
    end
    build_typus_list(formats, :header => 'export')
  end

  def previous_and_next(klass = @resource[:class])

    items = []

    if @next
      action = if klass.typus_user_id? && !@current_user.is_root?
                 @next.owned_by?(@current_user) ? 'edit' : 'show'
               else
                 !@current_user.can_perform?(klass, 'edit') ? 'show' : params[:action]
               end
      items << (link_to _("Next"), params.merge(:action => action, :id => @next.id))
    end
    if @previous
      action = if klass.typus_user_id? && !@current_user.is_root?
                 @previous.owned_by?(@current_user) ? 'edit' : 'show'
               else
                 !@current_user.can_perform?(klass, 'edit') ? 'show' : params[:action]
               end
      items << (link_to _("Previous"), params.merge(:action => action, :id => @previous.id))
    end

    build_typus_list(items, :header => 'go_to')

  end

  def search

    typus_search = @resource[:class].typus_defaults_for(:search)
    return if typus_search.empty?

    search_by = typus_search.collect { |x| @resource[:class].human_attribute_name(x) }.to_sentence

    search_params = params.dup
    %w( action controller search page id ).each { |p| search_params.delete(p) }

    hidden_params = search_params.map { |key, value| hidden_field_tag(key, value) }

    <<-HTML
<h2>#{_("Search")}</h2>
<form action="/#{params[:controller]}" method="get">
<p><input id="search" name="search" type="text" value="#{params[:search]}"/></p>
#{hidden_params.sort.join("\n")}
</form>
<p class="tip">#{_("Search by")} #{search_by.downcase}.</p>
    HTML

  end

  def filters

    typus_filters = @resource[:class].typus_filters
    return if typus_filters.empty?

    current_request = request.env['QUERY_STRING'] || []

    returning(String.new) do |html|
      typus_filters.each do |key, value|
        case value
        when :boolean then      html << boolean_filter(current_request, key)
        when :string then       html << string_filter(current_request, key)
        when :datetime then     html << datetime_filter(current_request, key)
        when :belongs_to then   html << relationship_filter(current_request, key)
        when :has_and_belongs_to_many then
          html << relationship_filter(current_request, key, true)
        else
          html << "<p>#{_("Unknown")}</p>"
        end
      end
    end

  end

  def relationship_filter(request, filter, habtm = false)

    att_assoc = @resource[:class].reflect_on_association(filter.to_sym)
    class_name = att_assoc.options[:class_name] || ((habtm) ? filter.classify : filter.capitalize.camelize)
    model = class_name.constantize
    related_fk = (habtm) ? filter : att_assoc.primary_key_name

    params_without_filter = params.dup
    %w( controller action page ).each { |p| params_without_filter.delete(p) }
    params_without_filter.delete(related_fk)

    items = []

    returning(String.new) do |html|
      related_items = model.find(:all, :order => model.typus_order_by)
      if related_items.size > model.typus_options_for(:sidebar_selector)
        related_items.each do |item|
          switch = 'selected' if request.include?("#{related_fk}=#{item.id}")
          items << <<-HTML
<option #{switch} value="#{url_for params.merge(related_fk => item.id, :page => nil)}">#{item.typus_name}</option>
          HTML
        end
        model_pluralized = model.name.downcase.pluralize
        form = <<-HTML
<!-- Embedded JS -->
<script>
function surfto_#{model_pluralized}(form) {
  var myindex = form.#{model_pluralized}.selectedIndex
  if (form.#{model_pluralized}.options[myindex].value != "0") {
    top.location.href = form.#{model_pluralized}.options[myindex].value;
  }
}
</script>
<!-- /Embedded JS -->
<form class="form" action="#"><p>
  <select name="#{model_pluralized}" onChange="surfto_#{model_pluralized}(this.form)">
    <option value="#{url_for params_without_filter}">#{_("Filter by")} #{_(model.typus_human_name)}</option>
    #{items.join("\n")}
  </select>
</p></form>
        HTML
      else
        related_items.each do |item|
          switch = request.include?("#{related_fk}=#{item.id}") ? 'on' : 'off'
          items << (link_to item.typus_name, params.merge(related_fk => item.id, :page => nil), :class => switch)
        end
      end

      if form
        html << build_typus_list(items, :attribute => filter, :selector => true)
        html << form
      else
        html << build_typus_list(items, :attribute => filter)
      end

    end

  end

  def datetime_filter(request, filter)
    items = []
    %w( today last_few_days last_7_days last_30_days ).each do |timeline|
      switch = request.include?("#{filter}=#{timeline}") ? 'on' : 'off'
      options = { filter.to_sym => timeline, :page => nil }
      items << (link_to _(timeline.humanize), params.merge(options), :class => switch)
    end
    build_typus_list(items, :attribute => filter)
  end

  def boolean_filter(request, filter)
    items = []
    @resource[:class].typus_boolean(filter).each do |key, value|
      switch = request.include?("#{filter}=#{key}") ? 'on' : 'off'
      options = { filter.to_sym => key, :page => nil }
      items << (link_to _(value), params.merge(options), :class => switch)
    end
    build_typus_list(items, :attribute => filter)
  end

  def string_filter(request, filter)
    values = @resource[:class].send(filter)
    items = []
    values.each do |item|
      link_name, link_filter = (values.first.kind_of?(Array)) ? [ item.first, item.last ] : [ item, item ]
      switch = request.include?("#{filter}=#{link_filter}") ? 'on' : 'off'
      options = { filter.to_sym => link_filter, :page => nil }
      items << (link_to link_name.capitalize, params.merge(options), :class => switch)
    end
    build_typus_list(items, :attribute => filter)
  end

end