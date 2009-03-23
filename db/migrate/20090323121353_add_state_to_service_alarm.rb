class AddStateToServiceAlarm < ActiveRecord::Migration
  def self.up
    add_column :alarms, :service_state, :integer
  end

  def self.down
    remove_column :alarms, :service_state
  end
end
