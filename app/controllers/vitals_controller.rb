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

	before_filter :admin?

	def index
		@database_sizes = Vital.find(:last, :select => "dbtotalsize, dbsensorsize, dbservicesize",
																		:order => "timestamp",
																		:conditions => "clienthandler = 0")
		@main_processes = Vital.find_all_by_clienthandler 0
		@client_handler_processes = Vital.find_all_by_clienthandler 1

		# Convert to byte.  
		if !@database_sizes.blank?
			@db_total_size = @database_sizes.dbtotalsize.to_f*1024*1024
			@db_sensor_size = @database_sizes.dbsensorsize.to_f*1024*1024
			@db_service_size = @database_sizes.dbservicesize.to_f*1024*1024
		else
			@db_total_size = 0
			@db_sensor_size = 0
			@db_service_size = 0
		end

    # Database connections.
    res = ActiveRecord::Base.connection.select_one("SHOW STATUS WHERE Variable_name = 'Threads_connected'")
    @db_connections = res["Value"].to_i

    res = ActiveRecord::Base.connection.select_one("SHOW VARIABLES WHERE Variable_name = 'max_connections'")
    @db_connections_max = res["Value"].to_i

    @db_connections_difference = @db_connections_max - @db_connections
    if @db_connections_difference < 15
      @db_connections_difference_alarm = true
    else
      @db_connections_difference_alarm = false
    end
    
    # Number of services/hosts
    @monitored_hosts = Host.find(:all).size
    @monitored_services = Service.find(:all).size
	end
end
