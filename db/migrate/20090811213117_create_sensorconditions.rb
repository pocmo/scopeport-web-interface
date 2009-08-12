class CreateSensorconditions < ActiveRecord::Migration
  def self.up
    drop_table :sensor_conditions
    create_table :sensorconditions do |t|
      t.integer :host_id
      t.string :sensor, :length => 35
      t.string :operator, :length => 1
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :sensorconditions
  end
end
