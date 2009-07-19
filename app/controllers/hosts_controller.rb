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
      @hosts << { "name" => host.name,
                  "cpu1" => Recentsensorvalue.find_by_host_id_and_name(host.id, "cpu_load_average_1").value,
                  "cpu5" => Recentsensorvalue.find_by_host_id_and_name(host.id, "cpu_load_average_5").value,
                  "cpu15" => Recentsensorvalue.find_by_host_id_and_name(host.id, "cpu_load_average_15").value,
                  "fm" => Recentsensorvalue.find_by_host_id_and_name(host.id, "free_memory").value,
                  "fs" => Recentsensorvalue.find_by_host_id_and_name(host.id, "free_swap").value,
                  "of" => Recentsensorvalue.find_by_host_id_and_name(host.id, "open_files").value,
                  "fi" => Recentsensorvalue.find_by_host_id_and_name(host.id, "free_inodes").value,
                  "rp" => Recentsensorvalue.find_by_host_id_and_name(host.id, "running_processes").value,
                  "tp" => Recentsensorvalue.find_by_host_id_and_name(host.id, "total_processes").value }
    end
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
      flash[:notice] = "Host has been added!"
      log("added", "a host", [@host.name, @host.id])
			redirect_to :controller => "overview"
		else
      flash[:error] = "Could not add host."
			render :action => "new"
		end
	end
end
