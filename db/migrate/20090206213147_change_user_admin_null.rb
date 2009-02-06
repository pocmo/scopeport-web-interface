class ChangeUserAdminNull < ActiveRecord::Migration
  def self.up
    change_column :users, :admin, :boolean, :default => 0
  end

  def self.down
    change_column :users, :admin, :boolean
  end
end
