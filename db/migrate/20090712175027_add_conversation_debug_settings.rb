class AddConversationDebugSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :conversation_logging_smtp, :boolean
    add_column :settings, :conversation_logging_xmpp, :boolean
  end

  def self.down
    remove_column :settings, :conversation_logging_smtp
    remove_column :settings, :conversation_logging_xmpp
  end
end
