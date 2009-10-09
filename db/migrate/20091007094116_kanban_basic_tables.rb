class KanbanBasicTables < ActiveRecord::Migration
  def self.up
    create_table  :projects do |t|
      t.timestamps
      t.string    :name
    end
    create_table  :lanes do |t|
      t.timestamps
      t.string    :title
      t.integer   :max_items,   :default => 0
      t.integer   :position
      t.integer   :super_lane_id
      t.integer   :project_id
      t.string   :type
    end
    create_table  :items do |t|
      t.timestamps
      t.date      :start_date,  :end_date
      t.string    :title
      t.text      :text
      t.integer   :owner_id
      t.float     :estimation
      t.integer   :lane_id
    end
    create_table  :history_entries do |t|
      t.timestamps
      t.string    :action
      t.string    :trigger_type
      t.integer   :trigger_id
      t.text      :delta
      t.integer   :item_id
    end
  end

  def self.down
    drop_table :projects
    drop_table :lanes
    drop_table :items
    drop_table :history_entries
  end
end
