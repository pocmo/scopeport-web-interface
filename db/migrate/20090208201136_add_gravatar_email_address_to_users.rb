class AddGravatarEmailAddressToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gravatar_email, :string
  end

  def self.down
    remove_column :userse, :gravatar_email
  end
end
