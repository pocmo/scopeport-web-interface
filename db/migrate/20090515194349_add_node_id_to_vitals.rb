class AddNodeIdToVitals < ActiveRecord::Migration
  def self.up
    add_column :vitals, :node_id, :integer
  end

  def self.down
    remove_column :vitals, :node_id
  end
end
