class CreateLastsensordata < ActiveRecord::Migration
  def self.up
		create_table :lastsensordata do |t|
			t.string :sv
			t.integer :st, :host, :timestamp
		end
  end

  def self.down
		drop_table :lastsensordata
  end
end
