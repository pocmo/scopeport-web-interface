class CreateConditiontemplates < ActiveRecord::Migration
  def self.up
    create_table :conditiontemplates do |t|
      t.string :name
      t.integer :conditiontemplatevalue_id
      t.timestamps
    end
  end

  def self.down
    drop_table :conditiontemplates
  end
end
