namespace :db do
  
  namespace :setup do
    desc "Basic setup with madvertise project, lanes and admin"
    task :madvertise => :environment do
      #user = User.create(:email => "admin@madvertise.de", :password => "admin", :password_confirmation => "admin")
      project = Project.create(:name => "Madvertise")
      restricted_lanes = %w(backlog live parking)
      standard_lanes = %w(selected in_progress development to_test deploy)
      sub_lanes = %w(in_progress done)
  
      restricted_lanes.each{|lane| RestrictedLane.create(:title => lane.humanize, :project => project)}
      standard_lanes.each_with_index{|lane, i| StandardLane.create(:title => lane.humanize, :project => project, :max_items => 6, :position => i + 1)}
      dev_lane = Lane.find_by_title 'Development'
      sub_lanes.each_with_index{|lane, i| StandardLane.create(:title => lane.humanize, :project => project, :super_lane_id => dev_lane.id, :position => i + 1)}
    end
  end
end