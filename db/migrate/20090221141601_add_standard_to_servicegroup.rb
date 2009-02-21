class AddStandardToServicegroup < ActiveRecord::Migration
  def self.up
    change_column :services, :servicegroup_id, :integer, :default => 0
  end

  def self.down
    add_column :services, :servicegroup_id, :integer
  end
end
