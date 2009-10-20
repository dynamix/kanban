class AddDashboardFlag < ActiveRecord::Migration
  def self.up
    add_column :lanes, :dashboard, :boolean, :default => true
  end

  def self.down
    remove_column :lanes, :dashboard
  end
end
