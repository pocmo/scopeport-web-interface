class AddPortToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :port, :integer
  end

  def self.down
    drop_column :nodes, :port
  end
end
