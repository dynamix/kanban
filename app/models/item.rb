class Item < ActiveRecord::Base
  has_many :history_items
  belongs_to :lane
  belongs_to :owner, :class_name => 'User'
end