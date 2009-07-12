class ConversationmessagesController < ApplicationController
  def index
    @smtp_conversations = Conversation.find_all_by_method "smtp", :order => "created_at DESC"
    @xmpp_conversations = Conversation.find_all_by_method "xmpp", :order => "created_at DESC"
  end

  def clear
    if Conversation.delete_all and Conversationmessage.delete_all
      flash[:notice] = "Conversation log has been cleared."
    else
      flash[:error] = "Could not clear conversation log."
    end
    redirect_to :action => "index"
  end

end
