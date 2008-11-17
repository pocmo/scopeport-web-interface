class Services < ActiveRecord::Migration
  def self.up
		create_table :services do |t|
			t.string :name, :host, :service_type
			t.integer :port, :responsetime, :maxres, :timeout, :warninggroup, :linkedhost, :state
			t.integer :lastcheck, :default => 0
			t.integer :lastwarn, :default => 0
			t.boolean :disabled, :default => 0
			t.timestamps
		end
  end

  def self.down
		drop_table :services
  end
end
