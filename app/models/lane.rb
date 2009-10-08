class Lane < ActiveRecord::Base
  belongs_to :project
  belongs_to :super_lane, :class_name => 'Lane', :foreign_key => 'super_lane_id'
  
  has_many :items, :order => "position"
  
  
end