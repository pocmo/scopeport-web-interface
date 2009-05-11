class ChangeNodes < ActiveRecord::Migration
  def self.up
    change_column :nodes, :consumption, :float
    add_column :nodes, :last_update, :integer
  end

  def self.down
    change_column :nodes, :consumption, :integer
    remove_column :nodes, :last_update
  end
end
