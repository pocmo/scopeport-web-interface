class RenameConversationmessageTypeToDirection < ActiveRecord::Migration
  def self.up
    rename_column :conversationmessages, :type, :direction
  end

  def self.down
    rename_column :conversationmessages, :direction, :type
  end
end
