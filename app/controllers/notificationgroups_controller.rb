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

class NotificationgroupsController < ApplicationController

	before_filter :permission?	
	
	def index
		@groups = Notificationgroupdetail.find :all
		@counts = Notificationgroup.count :conditions => "deleted = 0", :group => "warninggroup"
		@newGroup = Notificationgroupdetail.new
	end

	def show
		@group = Notificationgroupdetail.find params[:id] 
		@emailReceivers = Notificationgroup.find :all, 
															:conditions => { :warninggroup => params[:id], :email => "1", :deleted => "0" }
		@jabberReceivers = Notificationgroup.find :all, 
															:conditions => { :warninggroup => params[:id], :xmpp => "1", :deleted => "0" }
		@mobilecReceivers = Notificationgroup.find :all, 
															:conditions => { :warninggroup => params[:id], :mobilec => "1", :deleted => "0" }
		@newGroup = Notificationgroup.new
	end

	def creategroup
		@group = Notificationgroupdetail.new params[:newGroup]
		if @group.save
			flash[:notice] = "Notification group has been added!"
		else
			flash[:error] = "Could not add notification group. Did you fill out all required fields?"
		end
		redirect_to :action => "index"
	end

	def deletegroup
		@group = Notificationgroupdetail.find params[:id]
		@receivers = Notificationgroup.find :all, :conditions => { :warninggroup => params[:id] }

		if @receivers.length > 0
			@receivers.each do |receiver|
				myreceiver = Notificationgroup.find receiver.id
				if !myreceiver.destroy
					flash[:error] = "Could not delete all receivers of notification group"
					redirect_to :action => "show", :id => params[:id]
				end
			end
		end

		if @group.destroy
			flash[:notice] = "Notification group has been deleted!"
		else
			flash[:error] = "Could not delete notification group."
		end
		redirect_to :action => "index" 
	end

	def addreceiver
		if params[:id].blank? || params[:id].length <= 0
			flash[:error] = "Could not add receiver. Missing ID of Warninggroup."
			redirect_to :action => "index"
			return	
		end

		@receiver = Notificationgroup.new do |r|
			r.warninggroup = params[:id]
			r.sevborder = params[:newGroup][:sevborder]
			
			if !params[:newGroup][:mail].blank? && params[:newGroup][:mail].length > 0
				r.mail = params[:newGroup][:mail]
				r.email = 1
			else
				r.mail = "";
			end

			if !params[:newGroup][:jid].blank? && params[:newGroup][:jid].length > 0
				r.jid = params[:newGroup][:jid]
				r.xmpp = 1
			else
				r.jid = "";
			end
			
			if !params[:newGroup][:numberc].blank? && params[:newGroup][:numberc].length > 0
				r.numberc = params[:newGroup][:numberc]
				r.mobilec = 1
			else
				r.numberc = "";
			end

			if r.mail == "" && r.jid == "" && r.numberc == ""
				flash[:error] = "Could not add receiver. Missing fields."
	      redirect_to :action => "show", :id => params[:id]
	      return 
			end

			r.deleted = 0
		end

		if @receiver.save
			flash[:notice] = "Receiver has been added!"
		else
			flash[:error] = "Could not add receiver."
		end
		redirect_to :action => "show", :id => params[:id]
	end

	def deletereceiver
		if params[:id].blank? || params[:id].length <= 0
			flash[:error] = "Could not delete receiver. Missing ID."
			redirect_to :action => "index"
			return	
		end
	
		receiver = Notificationgroup.find(params[:id])
		if receiver.destroy
			flash[:notice] = "Receiver has been deleted!"
		else
			flash[:error] = "Could not delete receiver."
		end
		redirect_to :action => "index"
	end

	def show_receivers
		render :text => showAllNotificationReceivers
	end

end
