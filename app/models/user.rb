class User < ActiveRecord::Base
  acts_as_authentic
    
  has_many :items
  has_many :history_entries, :as => :trigger
end
