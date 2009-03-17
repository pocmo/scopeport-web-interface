class AddAttendeeToAlarms < ActiveRecord::Migration
  def self.up
    add_column :alarms, :attendee, :integer
  end

  def self.down
    remove_column :alarms, :attendee
  end
end
