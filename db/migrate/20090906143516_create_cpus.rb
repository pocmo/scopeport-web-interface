class CreateCpus < ActiveRecord::Migration
  def self.up
    create_table :cpus do |t|
      t.integer :host_id
      t.integer :core_number
      t.string :vendor
      t.string :model
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :cpus
  end
end
