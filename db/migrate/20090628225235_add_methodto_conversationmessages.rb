class AddMethodtoConversationmessages < ActiveRecord::Migration
  def self.up
    add_column :conversationmessages, :method, :string
  end

  def self.down
    remove_column :conversationmessages, :method
  end
end
