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
		status = Vital.find(:first)
		return if status.blank?
		
		last_update = Time.now - Time.at(status.timestamp)

		return if last_update.blank?

		if isProductionVersion? && (status.blank? || last_update > 300)
			return "<div id='server-not-running'>Warning: It seems like your ScopePort server is not running.</div>"
		end
		# Everything up to date. The server is running.
		return
	end

	def getNameOfWarningGroup groupID
		if groupID.blank? || groupID == 0
			return "None"
		end
		
		group = Notificationgroupdetail.find groupID
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
    user = User.find user_id
    settings = Setting.find :first

    if settings.blank? || settings.allow_gravatar.blank? || settings.allow_gravatar == false || user.blank? || user.gravatar_email.blank? || user.login.blank?
      return "<a href=\"/users/show/#{user.id}\">#{user.login}</a>"
    end

    require "md5"
    email_hash = MD5::md5 user.gravatar_email
    returnage = ""
    returnage << "<a href=\"/users/show/#{user.id}\" class=\"with-avatar\">"
    returnage << "<span><img src=\"http://www.gravatar.com/avatar/#{email_hash}?s=80\" alt=\"User avatar\" class=\"with-avatar\"></span>"
    returnage << "#{user.login}</a>"

    return returnage
  end

	#A method to block the admin pages to non-admin users
	def admin?
		#admin_controllers = %w{logmessages vitals setup}
		#admin_actions = %w{delete new}
		user = current_user
		if user != nil and !user.admin
			flash[:error] = "You must be admin to peform this action"
			redirect_back_or_default('/')
		end
	end
	
	#"Timer" to show in "Page generated in..."
	def start_time
		@start_time = Time.now
	end
end
