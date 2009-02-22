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

class LogmessagesController < ApplicationController

	before_filter :permission?	
	
	def index
		@headline = "Log"
		@logmessages = Logmessage.paginate :page => params[:page], :order => 'logtime DESC'
	end

	def clear
		Logmessage.connection.execute("TRUNCATE logmessages;")
		flash[:notice] = "Log has been cleared!"
		redirect_to :controller => "logmessages"
	end
end
