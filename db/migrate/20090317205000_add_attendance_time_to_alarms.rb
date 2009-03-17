class AddAttendanceTimeToAlarms < ActiveRecord::Migration
  def self.up
    add_column :alarms, :attendance_date, :datetime
  end

  def self.down
    remove_column :alarms, :attendance_date
  end
end
