ActionController::Routing::Routes.draw do |map|

  begin
    ActionController::Routing::Routes.recognize_path '/admin/typus_users'
  rescue
    map.connect ':controller/:action/:id'
  end

  begin
    ActionController::Routing::Routes.recognize_path '/admin/typus_users.csv'
  rescue
    map.connect ':controller.:format'
  end

end