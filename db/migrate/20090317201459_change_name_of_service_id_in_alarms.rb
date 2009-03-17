class ChangeNameOfServiceIdInAlarms < ActiveRecord::Migration
  def self.up
    rename_column :alarms, :serviceid, :service_id
  end

  def self.down
    rename_column :alarms, :service_id, :serviceid
  end
end
