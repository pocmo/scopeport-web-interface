class AddLastWarningTimeToSensorConditions < ActiveRecord::Migration
  def self.up
    add_column :sensorconditions, :last_warning, :integer
  end

  def self.down
    remove_column :sensorconditions, :last_warning
  end
end
