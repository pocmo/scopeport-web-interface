class AddUserIdToTopgraphs < ActiveRecord::Migration
  def self.up
    add_column :topgraphs, :user_id, :integer
  end

  def self.down
    remove_column :topgraphs, :user_id
  end
end
