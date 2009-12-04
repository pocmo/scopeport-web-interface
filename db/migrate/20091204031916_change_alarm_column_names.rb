class ChangeAlarmColumnNames < ActiveRecord::Migration
  def self.up
    rename_column :alarms, :hostid, :host_id
    rename_column :alarms, :st, :sensor
    rename_column :alarms, :sv, :value
  end

  def self.down
    rename_column :alarms, :host_id, :hostid
    rename_column :alarms, :sensor, :st
    rename_column :alarms, :value, :sv
  end
end
