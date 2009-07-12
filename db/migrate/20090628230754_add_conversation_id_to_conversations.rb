class AddConversationIdToConversations < ActiveRecord::Migration
  def self.up
    add_column :conversations, :conversation_id, :integer
  end

  def self.down
    remove_column :conversations, :conversation_id
  end
end
