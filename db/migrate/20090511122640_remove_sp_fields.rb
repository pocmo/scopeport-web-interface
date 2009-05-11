class RemoveSpFields < ActiveRecord::Migration
  def self.up
    remove_column :settings, :spserver
    remove_column :settings, :spport
  end

  def self.down
    add_column :settings, :spserver, :string
    add_column :settings, :spport, :integer
  end
end
