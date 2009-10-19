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
  
  def total_wip_for_item(item)
     total = item.wip_total || 0
     entry = item.current_lane_entry || Time.now
    distance_of_time_in_words(entry, Time.now+ total)
  end
  def current_wip_for_item(item)
    return nil if !item.current_lane_entry
    distance_of_time_in_words(item.current_lane_entry,Time.now)
  end
  
end
