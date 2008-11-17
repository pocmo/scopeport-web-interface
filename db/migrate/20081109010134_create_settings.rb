class CreateSettings < ActiveRecord::Migration
  def self.up
		create_table :settings do |t|
			t.string :spserver, :mail_server, :mail_user, :mail_pass, :mail_hostname, :mail_from
			t.string :xmpp_server, :xmpp_user, :xmpp_pass, :xmpp_resource, :mobilecUsername, :mobilecPassword
			t.string :mobilecAPIID
			t.integer :spport, :mail_port, :xmpp_port, :gnotigroup, :eg1, :eg2, :eg3
			t.boolean :mail_enabled, :mail_useauth, :mail_usetls, :xmpp_enabled, :doMobileClickatell
		end
  end

  def self.down
		drop_table :settings
  end
end
