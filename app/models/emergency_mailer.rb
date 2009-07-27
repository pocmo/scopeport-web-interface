class EmergencyMailer < ActionMailer::Base
  def load_settings
    @@smtp_settings = {
      :address => Setting.first.mail_server,
      :port => Setting.first.mail_port,
      :domain => Setting.first.mail_hostname,
      :authentication => :plain,
      :user_name => Setting.first.mail_user,
      :password => Setting.first.mail_pass
    }
  end

  def emergency_notification emergency, email, resend
    load_settings
    recipients  email
    from        Setting.first.mail_from
    if !resend
      subject     "[ScopePort] An emergency has been declared!"
    else
      subject     "[ScopePort] Notification about an emergency"
    end
    sent_on     Time.now
    body        :emergency => emergency, :resend => resend
  end

  def clickatell_emergency_notification emergency, phone_number, resend
    load_settings
    title = emergency.title[0, 69]
    title << "..." if emergency.title.length >= 70
    message_text = "user:#{Setting.last.mobilecUsername}\n"
    message_text << "password:#{Setting.last.mobilecPassword}\n"
    message_text << "api_id:#{Setting.last.mobilecAPIID}\n"
    message_text << "to:#{phone_number}\n"
    if !resend
      message_text << "text:[ScopePort] An emergency has been declared: \"#{title}\" "
    else
      message_text << "text:[ScopePort] Notification about an emergency: \"#{title}\" "
    end
    message_text << "Check the ScopePort Web Interface!"
    recipients  "sms@messaging.clickatell.com"
    from        Setting.first.mail_from
    if !resend
      subject     "[ScopePort] An emergency has been declared!"
    else
      subject     "[ScopePort] Notification about an emergency"
    end
    sent_on     Time.now
    body        message_text
  end
end
