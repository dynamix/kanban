module Admin::TableHelper

  def build_typus_table(model, fields, items, link_options = {}, association = nil)

    returning(String.new) do |html|

      html << <<-HTML
<table class="typus">
      HTML

      html << typus_table_header(model, fields)

      items.each do |item|

        html << <<-HTML
<tr class="#{cycle('even', 'odd')} #{item.class.name.underscore}" id="#{item.to_dom}" name="item_#{item.id}">
        HTML

        fields.each do |key, value|
          case value
          when :boolean then           html << typus_table_boolean_field(key, item)
          when :datetime then          html << typus_table_datetime_field(key, item, link_options)
          when :date then              html << typus_table_datetime_field(key, item, link_options)
          when :file then              html << typus_table_file_field(key, item, link_options)
          when :time then              html << typus_table_datetime_field(key, item, link_options)
          when :belongs_to then        html << typus_table_belongs_to_field(key, item)
          when :tree then              html << typus_table_tree_field(key, item)
          when :position then          html << typus_table_position_field(key, item)
          when :has_and_belongs_to_many then
            html << typus_table_has_and_belongs_to_many_field(key, item)
          else
            html << typus_table_string_field(key, item, link_options)
          end
        end

        action = if model.typus_user_id? && !@current_user.is_root?
                   # If there's a typus_user_id column on the table and logged user is not root ...
                   item.owned_by?(@current_user) ? item.class.typus_options_for(:default_action_on_item) : 'show'
                 elsif !@current_user.can_perform?(model, 'edit')
                   'show'
                 else
                   item.class.typus_options_for(:default_action_on_item)
                 end

        content = link_to _(action.capitalize), :controller => "admin/#{item.class.name.tableize}", :action => action, :id => item.id
        html << <<-HTML
<td width="10px">#{content}</td>
        HTML

        ##
        # This controls the action to perform. If we are on a model list we 
        # will remove the entry, but if we inside a model we will remove the 
        # relationship between the models.
        #
        # Only shown is the user can destroy/unrelate items.
        #

        trash = "<div class=\"sprite trash\">Trash</div>"
        unrelate = "<div class=\"sprite unrelate\">Unrelate</div>"

        case params[:action]
        when 'index'
          condition = if model.typus_user_id? && !@current_user.is_root?
                        item.owned_by?(@current_user)
                      else
                        @current_user.can_perform?(model, 'destroy')
                      end
          perform = link_to trash, { :action => 'destroy', :id => item.id }, 
                                     :title => _("Remove"), 
                                     :confirm => _("Remove entry?"), 
                                     :method => :delete if condition
        when 'edit'
          # If we are editing content, we can relate and unrelate always!
          perform = link_to unrelate, { :action => 'unrelate', :id => params[:id], :resource => model, :resource_id => item.id }, 
                                        :title => _("Unrelate"), 
                                        :confirm => _("Unrelate {{unrelate_model}} from {{unrelate_model_from}}?", 
                                        :unrelate_model => model.typus_human_name, 
                                        :unrelate_model_from => @resource[:human_name])
        when 'show'
          # If we are showing content, we only can relate and unrelate if we are 
          # the owners of the owner record.
          # If the owner record doesn't have a foreign key (Typus.user_fk) we look
          # each item to verify the ownership.
          condition = if @resource[:class].typus_user_id? && !@current_user.is_root?
                        @item.owned_by?(@current_user)
                      end
          perform = link_to unrelate, { :action => 'unrelate', :id => params[:id], :resource => model, :resource_id => item.id }, 
                                        :title => _("Unrelate"), 
                                        :confirm => _("Unrelate {{unrelate_model}} from {{unrelate_model_from}}?", 
                                        :unrelate_model => model.typus_human_name, 
                                        :unrelate_model_from => @resource[:human_name]) if condition
        end

        html << <<-HTML
<td width="10px">#{perform}</td>
</tr>
        HTML

      end

      html << "</table>"

    end

  end

  ##
  # Header of the table
  #
  def typus_table_header(model, fields)
    returning(String.new) do |html|
      headers = []
      fields.each do |key, value|

        content = model.human_attribute_name(key)
        content += " (#{key})" if key.include?('_id')

        if (model.model_fields.map(&:first).collect { |i| i.to_s }.include?(key) || model.reflect_on_all_associations(:belongs_to).map(&:name).include?(key.to_sym)) && params[:action] == 'index'
          sort_order = case params[:sort_order]
                       when 'asc'   then  ['desc', '&darr;']
                       when 'desc'  then  ['asc', '&uarr;']
                       else
                         [nil, nil]
                       end
          order_by = model.reflect_on_association(key.to_sym).primary_key_name rescue key
          switch = sort_order.last if params[:order_by].eql?(order_by)
          options = { :order_by => order_by, :sort_order => sort_order.first }
          content = (link_to "#{content} #{switch}", params.merge(options))
        end

        headers << "<th>#{content}</th>"

      end
      headers << "<th>&nbsp;</th>" if @current_user.can_perform?(model, 'delete')
      html << <<-HTML
<tr>
#{headers.join("\n")}
</tr>
      HTML
    end
  end

  def typus_table_belongs_to_field(attribute, item)

    action = item.send(attribute).class.typus_options_for(:default_action_on_item) rescue 'edit'

    att_value = item.send(attribute)
    content = if !att_value.nil?
      if @current_user.can_perform?(att_value.class.name, action)
        link_to item.send(attribute).typus_name, :controller => "admin/#{attribute.pluralize}", :action => action, :id => att_value.id
      else
        att_value.typus_name
      end
    end

    <<-HTML
<td>#{content}</td>
    HTML

  end

  def typus_table_has_and_belongs_to_many_field(attribute, item)
    <<-HTML
<td>#{item.send(attribute).map { |i| i.typus_name }.join('<br />')}</td>
    HTML
  end

  def typus_table_string_field(attribute, item, link_options = {})
    <<-HTML
<td class="#{attribute}">#{h(item.send(attribute))}</td>
    HTML
  end

  def typus_table_file_field(attribute, item, link_options = {})
    <<-HTML
<td>#{item.typus_preview_on_table(attribute)}</td>
    HTML
  end

  def typus_table_tree_field(attribute, item)
    <<-HTML
<td>#{item.parent.typus_name if item.parent}</td>
    HTML
  end

  def typus_table_position_field(attribute, item)

    html_position = []

    [['Up', 'move_higher'], ['Down', 'move_lower']].each do |position|

      options = { :controller => item.class.name.tableize, 
                  :action => 'position', 
                  :id => item.id, 
                  :go => position.last }

      first_or_last = (item.respond_to?(:first?) && (position.last == 'move_higher' && item.first?)) || (item.respond_to?(:last?) && (position.last == 'move_lower' && item.last?))
      html_position << link_to_unless(first_or_last, _(position.first), params.merge(options)) do |name|
        %(<span class="inactive">#{name}</span>)
      end
    end

    <<-HTML
<td>#{html_position.join(' / ')}</td>
    HTML

  end

  def typus_table_datetime_field(attribute, item, link_options = {} )

    date_format = item.class.typus_date_format(attribute)
    content = !item.send(attribute).nil? ? item.send(attribute).to_s(date_format) : item.class.typus_options_for(:nil)

    <<-HTML
<td>#{content}</td>
    HTML

  end

  def typus_table_boolean_field(attribute, item)

    boolean_hash = item.class.typus_boolean(attribute)
    status = item.send(attribute)
    link_text = !item.send(attribute).nil? ? boolean_hash["#{status}".to_sym] : item.class.typus_options_for(:nil)

    options = { :controller => item.class.name.tableize, :action => 'toggle', :field => attribute.gsub(/\?$/,''), :id => item.id }

    content = if item.class.typus_options_for(:toggle) && !item.send(attribute).nil?
                link_to link_text, params.merge(options), 
                                   :confirm => _("Change {{attribute}}?", 
                                   :attribute => item.class.human_attribute_name(attribute).downcase)
              else
                link_text
              end

    <<-HTML
<td align="center">#{content}</td>
    HTML

  end

end