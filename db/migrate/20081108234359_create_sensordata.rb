class CreateSensordata < ActiveRecord::Migration
  def self.up
		create_table :sensordata do |t|
			t.string :sv
			t.integer :st, :host, :timestamp
		end

		add_index :sensordata, :st, :unique => false
		add_index :sensordata, :host, :unique => false
  end

  def self.down
		drop_table :sensordata
  end
end
