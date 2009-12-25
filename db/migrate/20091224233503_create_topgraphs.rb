class CreateTopgraphs < ActiveRecord::Migration
  def self.up
    create_table :topgraphs do |t|
      t.integer :type
      t.integer :target_id
      t.string :target_sensor
      t.string :name
      t.integer :minutes
      t.timestamps
    end
  end

  def self.down
    drop_table :topgraphs
  end
end
