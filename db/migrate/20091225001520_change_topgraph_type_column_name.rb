class ChangeTopgraphTypeColumnName < ActiveRecord::Migration
  def self.up
    rename_column :topgraphs, :type, :graph_type
  end

  def self.down
    rename_column :topgraphs, :graph_type, :type
  end
end
