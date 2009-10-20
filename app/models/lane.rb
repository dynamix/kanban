class Lane < ActiveRecord::Base
  belongs_to :project
  belongs_to :super_lane, :class_name => 'Lane', :foreign_key => 'super_lane_id'
  
  has_many :sub_lanes, :class_name => 'Lane', :foreign_key => 'super_lane_id', :order => :position
  
  has_many :items, :order => "position"
  
  
  
  named_scope :restricted, :conditions => {:type => 'RestrictedLane', :super_lane_id => nil}, :order => :position
  
  def is_super_lane?
    sub_lanes.count > 0
  end
  
end