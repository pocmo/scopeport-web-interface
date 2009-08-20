class RemoveIdFromRecentsensorvaluesAndSetIndizes < ActiveRecord::Migration
  def self.up
    remove_column :recentsensorvalues, :id
    add_index :recentsensorvalues, :host_id
    add_index :recentsensorvalues, :name
  end

  def self.down
  end
end
