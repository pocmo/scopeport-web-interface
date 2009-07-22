class CreateEmergencychatmessages < ActiveRecord::Migration
  def self.up
    create_table :emergencychatmessages do |t|
      t.integer :user_id
      t.integer :emergency_id
      t.string :message
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :emergencychatmessages
  end
end
