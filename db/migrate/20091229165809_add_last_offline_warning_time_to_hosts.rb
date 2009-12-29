class AddLastOfflineWarningTimeToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :last_offline_warning, :datetime
  end

  def self.down
    remove_column :hosts, :last_offline_warning
  end
end
