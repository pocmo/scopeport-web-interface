class PrepareServicesForHandovers < ActiveRecord::Migration
  def self.up
    add_column :services, :reserved_for, :integer
    add_column :services, :reserved_on, :datetime
  end

  def self.down
    remove_column :services, :reserved_for
    remove_column :services, :reserved_on
  end
end
