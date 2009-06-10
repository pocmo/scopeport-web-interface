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

class HostsController < ApplicationController

	before_filter { |controller| controller.block unless controller.permission?}

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
