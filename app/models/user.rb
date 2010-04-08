class User < ActiveRecord::Base
  acts_as_authentic
    
  has_many :items
  has_many :statistics
  has_many :history_entries, :as => :trigger
  def to_s
    name
  end
end
