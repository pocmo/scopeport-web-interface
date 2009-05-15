class ChangeAlarmStatusNull < ActiveRecord::Migration
  def self.up
  	change_column :alarms, :status, :boolean, :default => 0
  end

  def self.down
 	  change_column :alarms, :status, :boolean
  end
end
