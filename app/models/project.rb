class Project < ActiveRecord::Base
  has_many :lanes
  has_one :backlog, :class_name => 'Lane', :conditions => {:title => 'Backlog'}
  
end