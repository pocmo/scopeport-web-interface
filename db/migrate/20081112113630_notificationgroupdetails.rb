class Notificationgroupdetails < ActiveRecord::Migration
  def self.up
		create_table :notificationgroupdetails do |t|
			t.string :name
			t.timestamps
		end
  end

  def self.down
		drop_table :notificationgroupdetails
  end
end
