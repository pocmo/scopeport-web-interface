class AddIndizes < ActiveRecord::Migration
  def self.up
    add_index :servicerecords, :serviceid

    add_index :sensorvalues, :name
    add_index :sensorvalues, :value

    add_index :services, :servicegroup_id
    
    add_index :networkinterfaces, :host_id

    add_index :hosts, :hostgroup_id

    add_index :emergencycomments, :emergency_id

    add_index :emergencychatusers, :emergency_id

    add_index :emergencychatmessages, :emergency_id

    add_index :servicecomments, :service_id

    add_index :cpus, :host_id

    add_index :conversationmessages, :conversation_id

    add_index :alarms, :service_id

    add_index :alarmcomments, :alarm_id
    add_index :alarmcomments, :user_id
  end

  def self.down
  end
end
