class CreateHostcomments < ActiveRecord::Migration
  def self.up
    create_table :hostcomments do |t|
			t.integer :host_id
      t.integer :user_id
      t.string :comment
      t.string :title
      t.timestamps
    end
    
    add_index :hostcomments, :host_id
    add_index :hostcomments, :user_id
  end

  def self.down
    drop_table :hostcomments
  end
end
