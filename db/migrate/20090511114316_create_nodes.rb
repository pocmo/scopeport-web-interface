class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :name
      t.string :ip_or_hostname
      t.integer :consumption
      t.datetime :takeoff
      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
