class AddTitleToEmergencyComments < ActiveRecord::Migration
  def self.up
    add_column :emergencycomments, :title, :string
  end

  def self.down
    remove_column :emergencycomments, :title
  end
end
