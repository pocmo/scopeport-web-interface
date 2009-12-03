class AddConditiontemplateIdToValues < ActiveRecord::Migration
  def self.up
    add_column :conditiontemplatevalues, :conditiontemplate_id, :integer
  end

  def self.down
    remove_column :conditiontemplatevalues, :conditiontemplate_id
  end
end
