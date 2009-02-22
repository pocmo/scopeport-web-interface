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

class SettingsController < ApplicationController

	before_filter :permission?
	  
  def index
   @notigroups = Notificationgroupdetail.find(:all).collect {|p| [p.name, p.id] }
   @notigroups << ["None", "0"]
   @settings = Setting.find(:first) || Setting.new()
  end

  def email
   @settings = Setting.find(:first) || Setting.new()
  end

  def xmpp
   @settings = Setting.find(:first) || Setting.new()
  end

  def mobilec
   @settings = Setting.find(:first) || Setting.new()
  end

  def save
  @count = Setting.find :all
   if @count.size > 0
    @settings = Setting.update(:first, params[:setting])
   else
    @settings = Setting.new(params[:setting])
   end

   @notigroups = Notificationgroupdetail.find(:all).collect {|p| [p.name, p.id] }
   @notigroups << ["None", "0"]
    
   if @settings.save
      flash[:notice] = "Settings saved"
      redirect_to :controller => "setup"      
   else
      flash[:error] = "Could not store settings. Please try again."
      redirect_to :controller => "setup"
   end
  end

end
