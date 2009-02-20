class AddGroupToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :servicegroup_id, :integer, :default => 0
  end

  def self.down
    remove_column :services, :servicegroup_id
  end
end
