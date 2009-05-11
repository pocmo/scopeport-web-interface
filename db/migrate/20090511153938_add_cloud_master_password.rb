class AddCloudMasterPassword < ActiveRecord::Migration
  def self.up
    add_column :settings, :cloud_master_password, :string, :default => "secret"
  end

  def self.down
    remove_column :settings, :cloud_master_password
  end
end
