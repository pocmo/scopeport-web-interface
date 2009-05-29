class RenameColumnUser < ActiveRecord::Migration
  def self.up
  	rename_column :users, :last_login, :last_online
  end

  def self.down
	  rename_column :users, :last_online, :last_login
  end
end
