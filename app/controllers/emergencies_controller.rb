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
      case @emergency.severity
        when 1: group_id = Setting.first.eg1
        when 2: group_id = Setting.first.eg2
        when 3: group_id = Setting.first.eg3
      end
      unless group_id.blank?
        sendEmergencyMessages @emergency, group_id
      end
      flash[:notice] = "Emergency has been declared! Sending notifications."
      redirect_to :controller => "hosts"
    else
      flash[:error] = "Could not declare emergency!"
      render :action => "new"
    end
  end

  def close
    emergency = Emergency.find params[:id]
    emergency.active = false
    if emergency.save
      Emergencychatmessage.delete_all [ "id = ?", params[:id] ]
      flash[:notice] = "Emergency has been closed."
      redirect_to :controller => "overview"
    else
      flash[:error] = "Could not close emergency!"
      redirect_to :action => "show", :id => emergency.id
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

  private

  def sendEmergencyMessages emergency, group_id
    # Email
    if Setting.last.mail_enabled
      email_receivers = Notificationgroup.find_all_by_email_and_warninggroup 1, group_id
      email_receivers.each do |receiver|
        begin
          EmergencyMailer.deliver_emergency_notification emergency, receiver.mail
        rescue
          next
        end
      end
    end

    # XMPP
    if Setting.last.xmpp_enabled
      require 'xmpp4r/client'
      xmpp_user = Setting.first.xmpp_user
      xmpp_server = Setting.first.xmpp_server
      xmpp_resource = Setting.first.xmpp_resource
      xmpp_password = Setting.first.xmpp_pass
      xmpp_receivers = Notificationgroup.find_all_by_xmpp_and_warninggroup 1, group_id
      xmpp_receivers.each do |receiver|
        begin
          require 'xmpp4r/client'
          jid = Jabber::JID::new "#{xmpp_user}@#{xmpp_server}/#{xmpp_resource}"
          cl = Jabber::Client::new jid
          cl.connect
          cl.auth xmpp_password

          # We are authenticated. Send the XMPP message.
          to = receiver.jid
          subject = "[ScopePort] An emergency has been declared!"
          body = "#{emergency.user.name} (#{emergency.user.login}) has just declared an emergency:"
          body << "\n\nTitle: #{emergency.title}"
          body << "\nDate: #{emergency.created_at}"
          body << "\n\n---- Description ----"
          body << "\n#{emergency.description}"
          body << "\n---------------------"
          body << "\n\nCoordinate countermeasures in the ScopePort Web Interface! There will be a notification about active emergencies."
          m = Jabber::Message::new(to, body).set_type(:normal).set_id('1').set_subject(subject)
          cl.send m
        rescue
          next
        end
      end
    end

    # Clickatell SMS API
    if Setting.last.mail_enabled and Setting.last.doMobileClickatell
      mobilec_receivers = Notificationgroup.find_all_by_mobilec_and_warninggroup 1, group_id
      mobilec_receivers.each do |receiver|
        #begin
          EmergencyMailer.deliver_clickatell_emergency_notification emergency, receiver.numberc
        #rescue
          #next
        #end
      end
    end
  end
end
