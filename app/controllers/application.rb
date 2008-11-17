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

end
