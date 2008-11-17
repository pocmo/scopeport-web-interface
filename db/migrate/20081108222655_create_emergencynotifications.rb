class CreateEmergencynotifications < ActiveRecord::Migration
  def self.up
		create_table :emergencynotifications do |t|
			t.integer :emergencyid, :notifiedon
			t.string :email, :jid, :numberc
		end
  end

  def self.down
		drop_table :emergencynotifications
  end
end
