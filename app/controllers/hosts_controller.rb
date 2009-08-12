# This file is part of ScopePort (Web Interface).
#
# Copyright 2007, 2008, 2009 Lennart Koopmann
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

class HostsController < ApplicationController

	before_filter { |controller| controller.block unless controller.permission?}

  def index
    @raw_hosts = Host.find :all
    @hosts = Array.new
    @raw_hosts.each do |host|
      @hosts << { "id" => host.id,
                  "name" => host.name,
                  "cpu1" => getLastSensorValue(host.id, "cpu_load_average_1"),
                  "cpu5" => getLastSensorValue(host.id, "cpu_load_average_5"),
                  "cpu15" => getLastSensorValue(host.id, "cpu_load_average_15"),
                  "fm" => getLastSensorValue(host.id, "free_memory"),
                  "fs" => getLastSensorValue(host.id, "free_swap"),
                  "of" => getLastSensorValue(host.id, "open_files"),
                  "fi" => getLastSensorValue(host.id, "free_inodes"),
                  "rp" => getLastSensorValue(host.id, "running_processes"),
                  "tp" => getLastSensorValue(host.id, "total_processes") }
    end
  end

  def show
    @host = Host.find params[:id]
  end

	def new
		@host = Host.new
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }
	end

	def create
		@host = Host.new params[:host]
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }
		
    if @host.save
      log("added", "a host", [@host.name, @host.id])
      flash[:notice] = "Host has been added!"
      log("added", "a host", [@host.name, @host.id])
			redirect_to :controller => "overview"
		else
      flash[:error] = "Could not add host."
			render :action => "new"
		end
	end

  private

  def getLastSensorValue host_id, sensor_name
    sensor = Recentsensorvalue.find_by_host_id_and_name host_id, sensor_name
    return "N/A" if sensor.blank?
    return sensor.value
  end

end
