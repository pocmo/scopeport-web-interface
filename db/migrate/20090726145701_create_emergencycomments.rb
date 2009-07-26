class CreateEmergencycomments < ActiveRecord::Migration
  def self.up
    create_table :emergencycomments do |t|
      t.integer :emergency_id
      t.integer :user_id
      t.string :comment
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :emergencycomments
  end
end
