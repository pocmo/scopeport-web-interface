class CreateDowntimes < ActiveRecord::Migration
  def self.up
		create_table :downtimes do |t|
			t.boolean :scheduled
			t.integer :hostid, :serviceid, :from, :to, :type
			t.text :comment
			t.timestamps
		end
  end

  def self.down
		drop_table :downtimes
  end
end
