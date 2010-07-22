class Lane < ActiveRecord::Base
  
  acts_as_list
  
  belongs_to :project
  belongs_to :super_lane, :class_name => 'Lane', :foreign_key => 'super_lane_id'
  
  has_many :sub_lanes, :class_name => 'Lane', :foreign_key => 'super_lane_id', :order => :position
  
  has_many :items, :order => "position"
  
  has_many :statistics
  
  named_scope :on_dashboard, :conditions => {:dashboard => true}
  named_scope :top_level, :conditions => {:super_lane_id => nil}, :order => :position
  named_scope :standard, :conditions => {:type => 'StandardLane', :super_lane_id => nil}, :order => :position
  named_scope :restricted, :conditions => {:type => 'RestrictedLane', :super_lane_id => nil}, :order => :position
  
  def is_super_lane?
    sub_lanes.count > 0
  end
  
  def name
    title.gsub(/\s/, "_").downcase
  end
  
  def can_take_more_items?
    max_items == 0 ||  items.count < max_items
  end
  
  def self.test_lane_id
    lane = find_by_title "Testing"
    lane ? lane.id : -1
  end
  
  def self.progress_lane_id
    lane = find_by_title "In progress"
    lane ? lane.id : -1
  end
  
  def self.ids_not_wip_relevant
    find(:all, :conditions => ["title IN (?)", ["Backlog", "Live", "Selected", "Live - Junkyard"]]).map_by_id
  end
  
end