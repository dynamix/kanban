namespace :db do
  
  namespace :setup do
    desc "Basic setup with madvertise project, lanes and admin"
    task :demo => :environment do
      user = User.create(:email => "admin@demo.de", :password => "admin", :password_confirmation => "admin", :name => 'admin')
      project = Project.create(:name => "Demo")
      restricted_lanes = %w(backlog live parking)
      standard_lanes = %w(selected development to_test deploy)
      sub_lanes = %w(in_progress done)
  
      restricted_lanes.each{|lane| RestrictedLane.create(:title => lane.humanize, :project => project)}
      standard_lanes.each{|lane| StandardLane.create(:title => lane.humanize, :project => project, :max_items => 6)}
      dev_lane = Lane.find_by_title 'Development'
      sub_lanes.each{|lane| StandardLane.create(:title => lane.humanize, :project => project, :super_lane_id => dev_lane.id)}
    end
  end
end