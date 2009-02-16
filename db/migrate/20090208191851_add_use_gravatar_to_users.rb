class AddUseGravatarToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :use_gravatar, :boolean, :standard => 0
  end

  def self.down
    remove_column :users, :use_gravatar
  end
end
