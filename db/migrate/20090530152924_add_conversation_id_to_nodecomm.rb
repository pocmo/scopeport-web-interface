class AddConversationIdToNodecomm < ActiveRecord::Migration
  def self.up
    add_column :nodecommunications, :conversation_id, :integer
  end

  def self.down
    remove_column :nodecommunications, :conversation_id
  end
end
