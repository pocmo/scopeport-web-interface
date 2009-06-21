class CreateAlarmcomments < ActiveRecord::Migration
  def self.up
    create_table :alarmcomments do |t|
			t.integer :alarm_id
      t.integer :user_id
      t.string :comment
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :alarmcomments
  end
end
