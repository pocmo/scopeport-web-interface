class ChangeTakeoffType < ActiveRecord::Migration
  def self.up
    change_column :nodes, :takeoff, :integer
  end

  def self.down
    change_column :nodes, :takeoff, :datetime
  end
end
