
# This file is part of ScopePort (Web Interface).
#
# Copyright 2009 Lennart Koopmann
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

class ServicegroupsController < ApplicationController
	
	before_filter { |controller| controller.block unless controller.permission?}
	
	def index
		@servicegroups = Servicegroup.find :all
		@new_group = Hostgroup.new
	end

	def create
		group = Servicegroup.new(params[:new_group])
		if group.save
			flash[:notice] = "Group has been added!"
		else
			flash[:error] = "Could not add group."
		end
		redirect_to :action => "index"
	end

	def show
		@group = Servicegroup.find params[:id]
		@members = Service.find_all_by_servicegroup_id params[:id]
	end

	def delete
    group = Servicegroup.find params[:id]
    if group.destroy
      # Reset the servicegroup_id of all hosts in this group.
      services = Service.find_all_by_servicegroup_id params[:id]
      services.each do |service|
        service.servicegroup_id = 0
        service.save
      end

      flash[:notice] = "Group has been deleted!"
    else
      flash[:error] = "Could not delete group."
    end
    redirect_to :action => "index"

	end

end
