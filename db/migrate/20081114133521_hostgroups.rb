class Hostgroups < ActiveRecord::Migration
  def self.up
		create_table :hostgroups do |t|
			t.string :name
		end
  end

  def self.down
		drop_table :hostgroups
  end
end
