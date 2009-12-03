class CreateConditiontemplatevalues < ActiveRecord::Migration
  def self.up
    create_table :conditiontemplatevalues do |t|
      t.string :sensor
      t.string :operator
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :conditiontemplatevalues
  end
end
