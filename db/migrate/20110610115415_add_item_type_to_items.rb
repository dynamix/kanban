class AddItemTypeToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :item_type, :string
  end

  def self.down
    remove_column :items, :item_type
  end
end
