class NewEmergencies < ActiveRecord::Migration
  def self.up
    drop_table :emergencies
    create_table :emergencies do |t|
      t.integer :severity
      t.string :title
      t.text :description
      t.boolean :active
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
  end
end
