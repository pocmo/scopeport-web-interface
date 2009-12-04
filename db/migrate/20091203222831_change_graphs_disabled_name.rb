class ChangeGraphsDisabledName < ActiveRecord::Migration
  def self.up
    rename_column :graphs, :show, :disabled
  end

  def self.down
    rename_column :graphs, :disabled, :show
  end
end
