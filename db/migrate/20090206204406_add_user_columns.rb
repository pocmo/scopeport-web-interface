class AddUserColumns < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login, :string
    add_column :users, :telephone_number, :string
    add_column :users, :description, :text
    add_column :users, :department_id, :integer
  end

  def self.down
    remove_column :users, :last_login
    remove_column :users, :telephone_number
    remove_column :users, :description
    remove_column :users, :department_id
  end
end
