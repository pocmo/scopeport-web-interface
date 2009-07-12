class Conversation < ActiveRecord::Base
  has_many :conversationmessages, :primary_key => :conversation_id, :foreign_key => :conversation_id
end
