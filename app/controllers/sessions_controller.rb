# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  skip_before_filter :login_required, :except => :destroy
  layout "login"
  
  def new
    # Is this the first admin user form?
    if User.find(:all).size == 0
      @first_admin = true
    else
      @first_admin = false
    end
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # welcome popup
#      host_alarms = Alarm.count :conditions => ["timestamp >= ? AND alarm_type = 1", user.last_online.to_datetime.to_f.to_i]
#      service_alarms = Alarm.count :conditions => ["timestamp >= ? AND alarm_type = 2", user.last_online.to_datetime.to_f.to_i]
#      session[:temporary_popups] = [{
#        "id"     => Digest::SHA1.hexdigest("login-popup"),
#        "title"  => "Hi " + user.login + "!",
#        "text"   => "You missed #{host_alarms} host alarms and #{service_alarms} service alarms in your absence.",
#        "sticky" => true,
#        "image"  => "/images/icons/info.png"
#      }]
      
      #Updates the last online attribute 
    	user.update_attribute("last_online", Time.now)
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      session[:login_at] = Time.now 
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_to :controller => "overview"
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      redirect_to :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out"
    redirect_to :action => "new"
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Login failed! Wrong username or password."
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
