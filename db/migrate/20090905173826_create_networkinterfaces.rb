class CreateNetworkinterfaces < ActiveRecord::Migration
  def self.up
    create_table :networkinterfaces do |t|
      t.integer :host_id
      t.string :name
      t.string :received
      t.string :sent
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :networkinterfaces
  end
end
