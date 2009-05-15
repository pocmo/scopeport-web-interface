class CreateCustomFilters < ActiveRecord::Migration
  def self.up
    create_table :custom_filters do |t|
    	t.integer :user_id
    	t.string :filters
    	t.string :name
    end
  end

  def self.down
    drop_table :custom_filters
  end
end
