class AddTimeCountersToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :wip_total, :integer
    add_column :items, :current_lane_entry, :datetime
  end

  def self.down
    remove_column :items, :current_lane_entry
    remove_column :items, :wip_total
  end
end
