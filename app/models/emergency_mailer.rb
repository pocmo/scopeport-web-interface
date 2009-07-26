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
end
