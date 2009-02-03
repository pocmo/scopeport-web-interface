class CreateServicecomments < ActiveRecord::Migration
  def self.up
    create_table :servicecomments do |t|
      t.integer :service_id
      t.integer :user_id
      t.string :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :servicecomments
  end
end
