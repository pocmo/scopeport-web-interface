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

class VitalsController < ApplicationController
	def index
		@databaseSizes = Vital.find(:last, :select => "dbtotalsize, dbsensorsize, dbservicesize",
																		:order => "timestamp",
																		:conditions => "clienthandler = 0")
		@mainThreads = Vital.find(:all, :conditions => "clienthandler = 0")
		@clienthandlerThreads = Vital.find(:all, :conditions => "clienthandler = 1")

		# Convert to byte.  
		if !@databaseSizes.blank?
			@dbTotalSize = @databaseSizes.dbtotalsize.to_f*1024*1024
			@dbSensorSize = @databaseSizes.dbsensorsize.to_f*1024*1024
			@dbServiceSize = @databaseSizes.dbservicesize.to_f*1024*1024
		else
			@dbTotalSize = 0
			@dbSensorSize = 0
			@dbServiceSize = 0
		end

	end
end
