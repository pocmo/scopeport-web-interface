class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.find_all_by_active true
  end

  def show
    @emergency = Emergency.find params[:id]
    @chat_message = Emergencychatmessage.new
  end

  def new
    @emergency = Emergency.new
  end

  def create
    @emergency = Emergency.new params[:emergency]
    @emergency.active = true
    @emergency.user_id = current_user.id
    if @emergency.save
      flash[:notice] = "Emergency has been declared! Notifications will be sent in a few seconds."
      redirect_to :controller => "hosts"
    else
      flash[:error] = "Could not declare emergency!"
      render :action => "new"
    end
  end

  def post_chat_message
    message = Emergencychatmessage.new params[:chat_message]
    message.user_id = current_user.id
    if message.save
      render :text => "okay"
    else
      render :text => "database error", :status => 500
    end
  end

  def get_chat_messages
    if params[:id].blank?
      render :text => "Missing emergency ID!", :status => 500
    end
  
    messages = Emergencychatmessage.find_all_by_emergency_id params[:id]
    returnage = ""
    
    if messages.blank?
      render :text => "<li>No chat messages</li>"
      return
    end

    messages.each do |message|
      user = User.find message.user_id
      if user.blank?
        username = "(unknown)"
      else
        username = user.login
      end
      returnage << "<li><span class=\"emergency-chat-message-date\">#{message.created_at}</span> "
      returnage << "<span class=\"emergency-chat-message-username\">#{username}</span>: "
      returnage << "<span class=\"emergency-chat-message-message\">#{message.message}</span></li>"
    end

    render :text => returnage

  end

end
