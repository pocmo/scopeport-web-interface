class CreateRecentsensorvalues < ActiveRecord::Migration
  def self.up
    drop_table :lastsensordata
    create_table :recentsensorvalues do |t|
      t.integer :host_id
      t.string :name
      t.string :value
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :recentsensorvalues
  end
end
