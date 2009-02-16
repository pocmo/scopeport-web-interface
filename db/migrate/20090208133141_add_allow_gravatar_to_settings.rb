class AddAllowGravatarToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :allow_gravatar, :boolean
  end

  def self.down
    remove_column :settings, :allow_gravatar
  end
end
