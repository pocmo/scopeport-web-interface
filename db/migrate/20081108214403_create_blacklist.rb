class CreateBlacklist < ActiveRecord::Migration
  def self.up
		create_table :blacklist do |t|
			t.string :host
			t.timestamps
		end
  end

  def self.down
		drop_table :blacklist
  end
end
