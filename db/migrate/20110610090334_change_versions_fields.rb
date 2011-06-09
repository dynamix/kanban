class ChangeVersionsFields < ActiveRecord::Migration
  def self.up
    change_table :versions do |t|
      t.belongs_to :user, :polymorphic => true
      t.integer :reverted_from
      t.rename :changes, :modifications

      t.index [:user_id, :user_type]
    end
  end

  def self.down
    change_table :versions do |t|
      t.remove :user_id, :user_type, :reverted_from
      t.rename :modifications, :changes
    end
  end
end
