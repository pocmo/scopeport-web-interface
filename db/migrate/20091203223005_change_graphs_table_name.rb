class ChangeGraphsTableName < ActiveRecord::Migration
  def self.up
    rename_table :graphs, :disabledgraphs
  end

  def self.down
    rename_table :disabledgraphs, :graphs
  end
end
