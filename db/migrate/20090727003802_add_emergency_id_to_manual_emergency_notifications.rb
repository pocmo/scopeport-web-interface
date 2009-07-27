class AddEmergencyIdToManualEmergencyNotifications < ActiveRecord::Migration
  def self.up
    add_column :manualemergencynotifications, :emergency_id, :integer
  end

  def self.down
    remove_column :manualemergencynotifications, :emergency_id
  end
end
