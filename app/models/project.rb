class Project < ActiveRecord::Base
  has_many :lanes, :order => :position
  has_one :backlog, :class_name => 'Lane', :conditions => {:title => 'Backlog'}
  
end