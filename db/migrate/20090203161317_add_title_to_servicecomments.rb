class AddTitleToServicecomments < ActiveRecord::Migration
  def self.up
    add_column :servicecomments, :title, :string
  end

  def self.down
    remove_column :servicecomments, :title
  end
end
