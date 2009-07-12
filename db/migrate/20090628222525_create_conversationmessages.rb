class CreateConversationmessages < ActiveRecord::Migration
  def self.up
    create_table :conversationmessages do |t|
      t.integer :conversation_id
      t.integer :type
      t.string :message
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :conversationmessages
  end
end
