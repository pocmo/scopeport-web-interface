class CreateSensors < ActiveRecord::Migration
  def self.up
		create_table :sensors do |t|
			t.integer :st, :standard_condition_value
			t.string :name, :standard_condition_type
			t.text :description
			t.boolean :overview, :needscondition, :hide
		end
  end

  def self.down
		drop_table :sensors
  end
end
