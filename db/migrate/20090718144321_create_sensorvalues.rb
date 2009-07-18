class CreateSensorvalues < ActiveRecord::Migration
  def self.up
    drop_table :sensordata
    create_table :sensorvalues do |t|
      t.integer :host_id
      t.string :name
      t.string :value
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :sensorvalues
  end
end
