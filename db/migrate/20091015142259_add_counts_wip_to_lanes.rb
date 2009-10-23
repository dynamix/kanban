class AddCountsWipToLanes < ActiveRecord::Migration
  def self.up
    add_column :lanes, :counts_wip, :boolean
    Lane.update_all("counts_wip = 1","id in (3,6,7,8,9)")
  end

  def self.down
    remove_column :lanes, :counts_wip
  end
end
