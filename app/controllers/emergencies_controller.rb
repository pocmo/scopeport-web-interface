class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.find_all_by_active true
  end

  def show
    @emergency = Emergency.find params[:id]
    @chat_message = Emergencychatmessage.new
    @new_comment = Emergencycomment.new
    @manually_sent_notifications = Manualemergencynotification.find_all_by_emergency_id params[:id]
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
        sendEmergencyMessages @emergency, group_id, false
      end
      flash[:notice] = "Emergency has been declared! Notifications have been sent."
      redirect_to :action => "show", :id => @emergency.id
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

  def manually_send_notification
    emergency = Emergency.find params[:emergency_id]

    # This is only allowed for admins and emergency owners.
    if !current_user.admin or emergency.user_id != current_user.id
      render :text => "not authorized"
      return
    end

    if !params[:notificationgroup_id].blank? and !emergency.blank?
      sendEmergencyMessages emergency, params[:notificationgroup_id], true
      inform = Manualemergencynotification.new
      inform.emergency_id = emergency.id
      inform.user_id = current_user.id
      inform.notificationgroupdetail_id = params[:notificationgroup_id]
      inform.save
      flash[:notice] = "Notifications have been sent."
    else
      flash[:error] = "Could not send notifications: Missing parameters!"
    end
    redirect_to :action => "show", :id => params[:emergency_id]
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
 
  def update_user_status
    if params[:id].blank? or params[:user_id].blank?
      render :text => nil
      return
    end
    user = Emergencychatuser.find_by_user_id_and_emergency_id params[:user_id], params[:id]
    if user.blank?
      # The user is not stored yet. Create.
      user = Emergencychatuser.new
      user.emergency_id = params[:id]
      user.user_id = params[:user_id]
      user.created_at = Time.now
      user.updated_at = Time.now
    else
      # The user is already stored. Update his timestamp.
      user.updated_at = Time.now
    end

    user.save

    render :text => nil
    return
  end

  def get_active_users
    emergency = Emergency.find_by_id params[:id]
    @users = emergency.all_active_chat_users
    render :partial => "get_active_users"
  end
 
  def store_comment
    comment = Emergencycomment.new params[:new_comment]

    emergency_id = params[:new_comment][:emergency_id]
    user_id = current_user.id
    if emergency_id.blank? || user_id.blank?
      flash[:error] = "Could not add comment: Missing parameters."
      redirect_to :action => "index"
      return
    end

    comment.emergency_id = emergency_id
    comment.user_id = user_id

    if comment.save
      flash[:notice] = "Comment has been added."
      log("commented", "on an emergency", comment.emergency_id)
    else
      flash[:error] = "Could not add comment! Please fill out all fields."
    end
    redirect_to :action => "show", :id => emergency_id
  end

  def deletecomment
    comment = Emergencycomment.find params[:id]
    if comment.nil?
      render :text => "Comment not found"
      return
    end

    # Only allow deletion of comments owned by this user.
    if comment.user_id == current_user.id
      if comment.destroy
        render :text => "Comment deleted."
      else
        render :text => "Could not delete comment."
      end
      return
    end

    render :text => "This is not your comment."
  end
  
  private

  def sendEmergencyMessages emergency, group_id, resend
    # Email
    if Setting.last.mail_enabled
      email_receivers = Notificationgroup.find_all_by_email_and_warninggroup 1, group_id
      email_receivers.each do |receiver|
        begin
          EmergencyMailer.deliver_emergency_notification emergency, receiver.mail, resend
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
          if !resend
            subject = "[ScopePort] An emergency has been declared!"
          else
            subject = "[ScopePort] Notification about an emergency!"
          end
          if !resend
            body = "#{emergency.user.name} (#{emergency.user.login}) has just declared an emergency:"
          else
            body = "This messsage informs you that #{emergency.user.name} (#{emergency.user.login}) has declared the following emergency on #{emergency.created_at}:"
          end
          body << "\n\nTitle: #{emergency.title}"
          body << "\nDate: #{emergency.created_at}"
          body << "\n\n---- Description ----"
          body << "\n#{emergency.description}"
          body << "\n---------------------"
          body << "\n\nCoordinate countermeasures in the ScopePort Web Interface! You will see a notification about active emergencies."
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
        begin
          EmergencyMailer.deliver_clickatell_emergency_notification emergency, receiver.numberc, resend
        rescue
          next
        end
      end
    end
  end
end
