class CreateSensorConditions < ActiveRecord::Migration
  def self.up
		create_table :sensor_conditions do |t|
			t.integer :hostid, :st, :lastwarn, :warninggroup, :severity
			t.string :type
			t.float :value
			t.boolean :disabled
		end
  end

  def self.down
		drop_table :sensor_conditions
  end
end
