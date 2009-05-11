class ChangeCloudMasterPassStandard < ActiveRecord::Migration
  def self.up
    change_column :settings, :cloud_master_password, :string, :default => "5ebe2294ecd0e0f08eab7690d2a6ee69"
  end

  def self.down
    change_column :settings, :cloud_master_password, :string, :default => "secret"
  end
end
