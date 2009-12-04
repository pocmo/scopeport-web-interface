class ChangeAlarmSensorColumnType < ActiveRecord::Migration
  def self.up
    change_column :alarms, :sensor, :string
  end

  def self.down
    change_column :alarms, :sensor, :integer
  end
end
