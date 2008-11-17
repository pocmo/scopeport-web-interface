class CreateServicedata < ActiveRecord::Migration
  def self.up
		create_table :servicedata do |t|
			t.integer :timestamp, :serviceid, :type, :ms
		end
  end

  def self.down
		drop_table :servicedata
  end
end
