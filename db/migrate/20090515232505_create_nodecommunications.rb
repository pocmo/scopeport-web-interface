class CreateNodecommunications < ActiveRecord::Migration
  def self.up
    create_table :nodecommunications, { :id => false } do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :type
      t.string :value
      t.datetime :timestamp
    end
  end

  def self.down
    drop_table :nodecommunications
  end
end
