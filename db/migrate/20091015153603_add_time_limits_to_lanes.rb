class AddTimeLimitsToLanes < ActiveRecord::Migration
  def self.up
    add_column :lanes, :warn_limit, :integer
    add_column :lanes, :urgent_limit, :integer
    Lane.update_all("warn_limit = 172800") # default: 3 days
    Lane.update_all("urgent_limit = 604800") # default: 7 days
  end

  def self.down
    remove_column :lanes, :urgent_limit
    remove_column :lanes, :warn_limit
  end
end
