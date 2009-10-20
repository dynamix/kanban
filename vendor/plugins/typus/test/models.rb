class Asset < ActiveRecord::Base

  belongs_to :resource, :polymorphic => true

end

class Category < ActiveRecord::Base

  acts_as_list if defined?(ActiveRecord::Acts::List)

  validates_presence_of :name
  has_and_belongs_to_many :posts

  def self.typus
  end

end

class Comment < ActiveRecord::Base

  validates_presence_of :name, :email, :body
  belongs_to :post

end

class CustomUser < ActiveRecord::Base
end

class Page < ActiveRecord::Base

  acts_as_tree if defined?(ActiveRecord::Acts::Tree)

end

class Post < ActiveRecord::Base

  validates_presence_of :title, :body
  has_and_belongs_to_many :categories
  has_many :assets, :as => :resource, :dependent => :destroy
  has_many :comments
  has_many :views
  belongs_to :favorite_comment, :class_name => 'Comment'

  def self.status
    %w( true false pending published unpublished )
  end

  def self.typus
    'plugin'
  end

  def asset_file_name
  end

end

class View < ActiveRecord::Base

  belongs_to :post

end

class Delayed::Task < ActiveRecord::Base

  set_table_name 'delayed_tasks'

end