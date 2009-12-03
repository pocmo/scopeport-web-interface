class CreateGraphs < ActiveRecord::Migration
  def self.up
    create_table :graphs do |t|
      t.integer :host_id
      t.string :name
      t.boolean :show
      t.timestamps
    end
  end

  def self.down
    drop_table :graphs
  end
end
