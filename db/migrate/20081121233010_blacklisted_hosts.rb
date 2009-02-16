class BlacklistedHosts < ActiveRecord::Migration
  def self.up
		create_table :blacklisted_hosts do |t|
			t.string :host
			t.timestamps
		end
  end

  def self.down
		dropt_table :blacklisted_hosts
  end
end
