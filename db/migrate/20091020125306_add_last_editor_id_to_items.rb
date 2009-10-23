class AddLastEditorIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :last_editor_id, :integer
  end

  def self.down
    remove_column :items, :last_editor_id
  end
end
