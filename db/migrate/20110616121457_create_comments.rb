class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :item
      t.references :user
      t.column :text, :string, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
