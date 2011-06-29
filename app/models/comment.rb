class Comment < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
  
  scope :for_item, lambda { |item_id| 
    {
      :conditions => {:item_id => item_id}
    }
  }
end
