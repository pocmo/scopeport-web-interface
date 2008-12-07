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
  helper :all # include all helpers, all the time

	helper_method :getLastLogMessage
	helper_method :getServerNotRunningMessage

	helper_method :getNameOfWarningGroup
	helper_method :getNameOfHost

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
		return false
	end

	# Tries to find out if the ScopePort server is running by
	# investigating the timestamps in the vitals table.
	def getServerNotRunningMessage
		status = Vital.find(:first)
		last_update = Time.now - Time.at(status.timestamp)

		return if last_update.blank?

		if isProductionVersion? && (status.blank? || last_update > 300)
			return "<div id='server-not-running'>It seems like your ScopePort server is not running.</div>"
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

	# This will generate the graphs of a given service. Returns true or false.
	def generateServiceGraphs service_id
		# Config.
		rrdtool_path = "/usr/bin/rrdtool"
		rrd_path = "/home/lennart/workspace/scopeport-web-interface/rrds/"
		
		# The complete path to this RRD.
		rrd = rrd_path + "service_" + service_id.to_s + "-response.rrd"

		# Return false if calling rrdtool fails.
		return false if !File.executable? rrdtool_path
		
		# RRD does not exist - Create it.
		if !File.exists? rrd
			# Command to create RRD.
			command = rrdtool_path + " create " + rrd + " --start NOW --step 60 DS:response:GAUGE:600:U:U RRA:AVERAGE:0.5:6:44640"

			# Return false if creating RRD failed.
			return false if !system command
		end

		# We now have a correct RRD in variable rrd. Fetch the service data to plot.
		data = Servicerecord.find :all

		# Everything went fine. - The graph has been updated.
		return true
	end

end
