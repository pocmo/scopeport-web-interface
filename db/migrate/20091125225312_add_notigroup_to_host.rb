class AddNotigroupToHost < ActiveRecord::Migration
  def self.up
    add_column :hosts, :notificationgroup_id, :integer
  end

  def self.down
    remove_column :hosts, :notificationgroup_id
  end
end
