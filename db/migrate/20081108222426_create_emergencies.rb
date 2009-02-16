class CreateEmergencies < ActiveRecord::Migration
  def self.up
		create_table :emergencies do |t|
			t.integer :timestamp, :reportedby, :severity
			t.string :name
			t.text :description
			t.boolean :active
		end
  end

  def self.down
		drop_table :emergencies
  end
end
