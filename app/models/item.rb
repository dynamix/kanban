class Item < ActiveRecord::Base
  # vestal_versions plugin
  # http://github.com/laserlemon/vestal_versions
  versioned

  has_many :history_entries
  belongs_to :lane
  belongs_to :owner, :class_name => 'User'
  
  acts_as_list :scope => :lane
end