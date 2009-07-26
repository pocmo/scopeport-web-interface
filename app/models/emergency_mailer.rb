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

  def emergency_notification(emergency, email)
    load_settings
    recipients  email
    from        Setting.first.mail_from
    subject     "[ScopePort] An emergency has been declared!"
    sent_on     Time.now
    body        :emergency => emergency
  end

  def clickatell_emergency_notification(emergency, phone_number)
    load_settings
    title = emergency.title[0, 69]
    title << "..." if emergency.title.length >= 70
    message_text = "user:#{Setting.last.mobilecUsername}\n"
    message_text << "password:#{Setting.last.mobilecPassword}\n"
    message_text << "api_id:#{Setting.last.mobilecAPIID}\n"
    message_text << "to:#{phone_number}\n"
    message_text << "text:[ScopePort] An emergency has been declared: \"#{title}\" Check the ScopePort Web Interface!"
    recipients  "sms@messaging.clickatell.com"
    from        Setting.first.mail_from
    subject     "[ScopePort] An emergency has been declared!"
    sent_on     Time.now
    body        message_text
  end
end
