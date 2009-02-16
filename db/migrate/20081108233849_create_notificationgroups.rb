class CreateNotificationgroups < ActiveRecord::Migration
  def self.up
		create_table :notificationgroups do |t|
			t.integer :warninggroup, :sevborder
			t.string :mail, :jid, :numberc
			t.boolean :email, :xmpp, :mobilec, :deleted
		end
  end

  def self.down
		drop_table :notificationgroups
  end
end
