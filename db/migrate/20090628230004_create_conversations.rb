class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations, :primary_key => :conversation_id do |t|
      t.string :method
      t.string :remote_host
      t.datetime :created_at
    end
    remove_column :conversationmessages, :method
  end

  def self.down
    drop_table :conversations
    add_column :conversationmessages, :method, :string
  end
end
