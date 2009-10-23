# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def js_behavior
    path = "#{RAILS_ROOT}/public/javascripts/behaviors"
    js_file = File.join(path, controller.controller_path + '.js')
     if File.exists?(js_file)
       controller_name = controller.controller_path.classify.split('::').last
       script = "
        _controller = new #{controller_name}Controller('#{controller.action_name}');
       "
       content_for(:dom_ready, script)
       return javascript_include_tag("behaviors/#{controller.controller_path}.js")
     end
  end
  
  def lane_params(lane, last = false)
    res = { :id => "#{lane.id}", :limit => lane.max_items }
    name = lane.title.gsub(/\s/, "_").downcase
    res[:class] = ""
    res[:class] += ' super ' if lane.is_super_lane?
    res[:class] += ' last ' if last
    res[:class] += ' top ' if lane.sub_lanes.length == 0 || lane.is_super_lane?
    res[:class] += ' ' + name + ' '
    res[:name] = name
    res
  end


  def time_distance_as_number_with_unit(distance)
    return '-' if distance == 0 || !distance
    old_r = 0
    [['s',60], ['m',60], ['h',24], ['d',24]].each do |symbol, divider|
      distance, r = distance.divmod(divider) 
      if symbol == 'd'
        sub = ((old_r/24.to_f)*10).truncate
        sub = sub > 0 ? ",#{sub}" : ""
      else
        sub = ""
      end
      old_r = r
      return "#{r.to_i}#{sub}#{symbol}" if distance == 0
    end
    result
  end

  def wip_for_item(item)
    return '-' if not item
    now = Time.now
    current = item.current_lane_entry ? (now - item.current_lane_entry) : 0
    total = now + (item.wip_total || 0) - (item.current_lane_entry || now)
    "#{time_distance_as_number_with_unit(current)} | #{time_distance_as_number_with_unit(total)}"
  end

  def total_wip_for_item(item)
     total = item.wip_total || 0
     entry = item.current_lane_entry || Time.now
    distance_of_time_in_words(entry, Time.now+ total)
  end

  def current_wip_for_item(item)
    return nil if !item.current_lane_entry
    distance_of_time_in_words(item.current_lane_entry,Time.now)
  end
  
  def klass(sym)
    {:class => sym}
  end
  
  
end
