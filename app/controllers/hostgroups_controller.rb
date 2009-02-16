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

class HostgroupsController < ApplicationController
	
	before_filter :admin?, :except => [:index, :show]
	
	def index
		@hostgroups = Hostgroup.find :all
		@newGroup = Hostgroup.new
	end

	def create
		@group = Hostgroup.new(params[:newGroup])
		if @group.save
			flash[:notice] = "Host group has been added!"
		else
			flash[:error] = "Could not add host group."
		end
		redirect_to :action => "index"
	end

	# Fetches requested host group and it's members.
	def show
		@group = Hostgroup.find params[:id]
		@members = Host.find_all_by_hostgroup_and_disabled(params[:id], 0)
	end

	def delete
    if params[:id].blank? || params[:id].length <= 0
      flash[:error] = "Could not delete group. Missing ID."
      redirect_to :action => "index"
      return
    end

    group = Hostgroup.find(params[:id])
    if group.destroy
      flash[:notice] = "Group has been deleted!"
    else
      flash[:error] = "Could not delete group."
    end
    redirect_to :action => "index"

	end

end
