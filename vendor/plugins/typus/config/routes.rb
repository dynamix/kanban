ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'typus', :path_prefix => 'admin' do |i|
    i.admin_quick_edit 'quick_edit', :action => 'quick_edit'
    i.admin_dashboard '', :action => 'dashboard'
    i.admin_sign_in 'sign_in', :action => 'sign_in'
    i.admin_sign_out 'sign_out', :action => 'sign_out'
    i.admin_sign_up 'sign_up', :action => 'sign_up'
    i.admin_recover_password 'recover_password', :action => 'recover_password'
    i.admin_reset_password 'reset_password', :action => 'reset_password'
  end

end