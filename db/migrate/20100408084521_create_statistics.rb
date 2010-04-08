class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.timestamps
      t.datetime :entry_time, :leave_time
      t.references :item, :lane, :user
      t.integer :duration
    end
  end

  def self.down
    drop_table :statistics
  end
end
