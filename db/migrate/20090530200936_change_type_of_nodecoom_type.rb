class ChangeTypeOfNodecoomType < ActiveRecord::Migration
  def self.up
    change_column :nodecommunications, :type, :string
  end

  def self.down
    change_column :nodecommunications, :type, :integer
  end
end
