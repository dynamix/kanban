class Comment < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
  validates :text, :presence => true
  
  scope :for_item, lambda { |item_id| 
    {
      :conditions => {:item_id => item_id},
      :order => "created_at DESC"
    }
  }
end
