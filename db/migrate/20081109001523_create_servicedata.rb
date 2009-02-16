class CreateServicedata < ActiveRecord::Migration
  def self.up
		create_table :servicerecords do |t|
			t.integer :timestamp, :serviceid, :ms
		end
  end

  def self.down
		drop_table :servicerecords
  end
end
