class CreateManualemergencynotifications < ActiveRecord::Migration
  def self.up
    create_table :manualemergencynotifications do |t|
      t.integer :user_id
      t.integer :notificationgroupdetail_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :manualemergencynotifications
  end
end
