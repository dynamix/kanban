module Admin::MasterHelper

  include TypusHelper

  include Admin::SidebarHelper
  include Admin::FormHelper
  include Admin::TableHelper

  def display_link_to_previous

    options = {}
    options[:resource_from] = @resource[:human_name]
    options[:resource_to] = params[:resource].classify.humanize if params[:resource]

    editing = %w( edit update ).include?(params[:action])

    message = case
              when params[:resource] && editing
                _("You're updating a {{resource_from}} for {{resource_to}}.", 
                  :resource_from =>  options[:resource_from], 
                  :resource_to => options[:resource_to])
              when editing
                _("You're updating a {{resource_from}}.", 
                  :resource_from => options[:resource_from])
              when params[:resource]
                _("You're adding a new {{resource_from}} to {{resource_to}}.", 
                  :resource_from => options[:resource_from], 
                  :resource_to => options[:resource_to])
              else
                _("You're adding a new {{resource_from}}.", 
                  :resource_from => options[:resource_from] )
              end

    returning(String.new) do |html|
      html << <<-HTML
<div id="flash" class="notice">
  <p>#{message} #{link_to _("Do you want to cancel it?"), params[:back_to]}</p>
</div>
      HTML
    end

  end

  def remove_filter_link(filter = request.env['QUERY_STRING'])
    return unless filter && !filter.blank?
    <<-HTML
<small>#{link_to _("Remove filter")}</small>
    HTML
  end

  ##
  # If there's a partial with a "microformat" of the data we want to 
  # display, this will be used, otherwise we use a default table which 
  # it's build from the options defined on the yaml configuration file.
  #
  def build_list(model, fields, items, resource = @resource[:self], link_options = {}, association = nil)

    template = "app/views/admin/#{resource}/_#{resource.singularize}.html.erb"

    if File.exist?(template)
      render :partial => template.gsub('/_', '/'), :collection => items, :as => :item
    else
      build_typus_table(model, fields, items, link_options, association)
    end

  end

  def pagination(*args)
    @options = args.extract_options!
    render 'admin/shared/pagination' if @items.prev || @items.next
  end

  ##
  # Simple and clean pagination links
  #
  def build_pagination(pager, options = {})

    options[:link_to_current_page] ||= true
    options[:always_show_anchors] ||= true

    # Calculate the window start and end pages
    options[:padding] ||= 2
    options[:padding] = options[:padding] < 0 ? 0 : options[:padding]

    page = params[:page].blank? ? 1 : params[:page].to_i
    current_page = pager.page(page)

    first = pager.first.number <= (current_page.number - options[:padding]) && pager.last.number >= (current_page.number - options[:padding]) ? current_page.number - options[:padding] : 1
    last = pager.first.number <= (current_page.number + options[:padding]) && pager.last.number >= (current_page.number + options[:padding]) ? current_page.number + options[:padding] : pager.last.number

    returning(String.new) do |html|
      # Print start page if anchors are enabled
      html << yield(1) if options[:always_show_anchors] and not first == 1
      # Print window pages
      first.upto(last) do |page|
        (current_page.number == page && !options[:link_to_current_page]) ? html << page.to_s : html << (yield(page)).to_s
      end
      # Print end page if anchors are enabled
      html << yield(pager.last.number).to_s if options[:always_show_anchors] and not last == pager.last.number
    end

  end

end