class AddServiceAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :service_admin, :boolean
  end

  def self.down
    remove_column :users, :service_admin
  end
end
