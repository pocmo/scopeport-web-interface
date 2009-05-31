# This file is part of ScopePort (Web Interface).
#
# Copyright 2007, 2008 Lennart Koopmann
#
# ScopePort (Web Interface) is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ScopePort (Web Interface) is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ScopePort (Web Interface).  If not, see <http://www.gnu.org/licenses/>.

class ApplicationController < ActionController::Base
  before_filter :start_time
    
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

	helper_method :getLastLogMessage
	helper_method :getServerNotRunningMessage

	helper_method :getNameOfWarningGroup
	helper_method :getNameOfHost

  helper_method :buildUserLink

  before_filter :login_required
	before_filter :update_last_online
	
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '7ff73c4e87f55ca1949926d59b1ec12d'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
 
	def getLastLogMessage
		message = Logmessage.find(:last, :order => "logtime DESC")
		if message.blank?
			return "No log messages"
		return message.logmsg
		end
	end

	# Returns if this is a production version. I.e. used to not display
	# "server not running" message in development versions.
	def isProductionVersion?
		return true
	end

	# Tries to find out if the ScopePort server is running by
	# investigating the timestamps in the vitals table.
	def getServerNotRunningMessage
    nodes = Node.find :all

    offline = 0
    nodes.each do |node|
      offline+=1 if (!node.last_update.blank? and (Time.now.to_i-15)-node.last_update > 0) or node.consumption.blank?
    end

		if isProductionVersion? and offline == nodes.size
			return "<div id='server-not-running'>Warning: It seems like there is no ScopePort node running.</div>
              <script type='text/javascript'>Effect.Pulsate('server-not-running', { pulses: 9001, duration: 10002 });</script>"
		end
		# Everything up to date. The server is running.
		return
	end

	def getNameOfWarningGroup groupID
		if groupID.blank? || groupID == 0
			return "None"
		end
		
    begin
		  group = Notificationgroupdetail.find groupID
    rescue
      return "None"
    end

    if group.blank?
			return "None"
		end

		return group.name
	end

	def getNameOfHost hostID
		return "None"
	end

	def showAllNotificationReceivers
		emailReceivers = Notificationgroup.find_all_by_email_and_warninggroup 1, params[:id]
		xmppReceivers = Notificationgroup.find_all_by_xmpp_and_warninggroup 1, params[:id]
		mobilecReceivers = Notificationgroup.find_all_by_mobilec_and_warninggroup 1, params[:id]

		returnage = "
				<div id=\"notigroupdetails\">
					<img alt=\"Email\" src=\"/images/icons/email.png\" style=\"float: left\" /> <h3>Email</h3>
					<ul>"
		if emailReceivers.length > 0
			emailReceivers.each do |receiver|
				returnage << "<li>" + receiver.mail + "</li>"
			end
		else
			returnage << "<li>No email receivers</li>"
		end
		returnage << "</ul></div>";
		
		returnage << "
				<div id=\"notigroupdetails\">
					<img alt=\"XMPP\" src=\"/images/icons/xmpp.png\" style=\"float: left\" /> <h3>Jabber/XMPP</h3>
					<ul>"
		if xmppReceivers.length > 0
			xmppReceivers.each do |receiver|
				returnage << "<li>" + receiver.jid + "</li>"
			end
		else
			returnage << "<li>No XMPP/Jabber receivers</li>"
		end
		returnage << "</ul></div>";

		returnage << "
				<div id=\"notigroupdetails\">
					<img alt=\"Mobile - Clickatell API\" src=\"/images/icons/mobilec.png\" style=\"float: left\" /> <h3>Clickatell SMS API</h3>
					<ul>"
		if mobilecReceivers.length > 0
			mobilecReceivers.each do |receiver|
				returnage << "<li>+" + receiver.numberc + "</li>"
			end
		else
			returnage << "<li>No Clickatell SMS API receivers</li>"
		end
		returnage << "</ul></div>";

		return returnage
	end

  def buildUserLink user_id
    returnage = ""

    begin
      user = User.find user_id
      settings = Setting.find :first
    rescue
      return "User not found"
    end

    if settings.blank? or user.blank? or user.login.blank?
      return "User not found"
    end
    
    department = nil

    # Add the department if the user has been assigned to one.
    unless user.department_id.blank?
      begin
        department = Department.find user.department_id
      rescue
        department = "Unknown"
      end
    end

    # Check if we have to deliver with Gravatar.
    if settings.allow_gravatar.blank? or settings.allow_gravatar == false or user.gravatar_email.blank? or user.use_gravatar.blank?
      returnage << "<a href=\"/users/show/#{user.id}\">"
      returnage << user.login
      returnage << "</a>"
      unless department.blank? or department.name.blank?
        returnage << " <span style=\"font-weight: normal;\">(Department: " << department.name << ")</span>"
      end
      return returnage
    end

    require "md5"
    email_hash = MD5::md5 user.gravatar_email
    returnage << "<a href=\"/users/show/#{user.id}\" class=\"with-avatar\">"
    returnage << "<span><img src=\"http://www.gravatar.com/avatar/#{email_hash}?s=80\" alt=\"User avatar\" class=\"with-avatar\"></span>"
    returnage << "#{user.login}</a>"
    unless department.blank? or department.name.blank?
      returnage << " <span style=\"font-weight: normal;\">(Department: " << department.name << ")</span>"
    end

    return returnage
  end

	#A method to block the admin pages to non-admin users
def permission?
    user = current_user
    controller = params[:controller]
    action = params[:action]
    id = params[:id]
    
    #First access, permission to create the first admin user
    return true if User.find(:all).size == 0
    
    # Okay, the user is an administrator. Allow all access.
    return true if user.admin
 
    # Fine grained access rules.
    # Allow changing own profile.
    return true if controller == "users" and (action == "edit" or action == "update") and id == user.id.to_s
 		
 		# Service Admin
 		return true if (controller == "services" or controller == "servicegroups" or controller == "notificationgroups") and user.service_admin
 
 		return false
  end
	
	#Method to redirect to root when a person don't have permission to do something
	def block
		flash[:error] = "Sorry. You must be an administrator to perform this action."
		redirect_back_or_default('/')
	end
	
	#"Timer" to show in "Page generated in..."
	def start_time
		@start_time = Time.now
	end
  
  def update_last_online
  	current_user.update_attribute("last_online", Time.now) if current_user
  end
  
end
