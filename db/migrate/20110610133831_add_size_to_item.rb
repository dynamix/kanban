class AddSizeToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :size, :string
  end

  def self.down
    remove_column :items, :size
  end
end
