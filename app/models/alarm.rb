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

class Alarm < ActiveRecord::Base
  belongs_to :service
  has_one :user, :primary_key => :attendee, :foreign_key => :id
	has_many :alarmcomments, :order => "created_at DESC"
	
	named_scope :time, lambda { |time|  { :conditions => ["timestamp > ?", time.to_i ] } }
	named_scope :status, lambda { |status| {:conditions => { :status => status } } }
	named_scope :from_service, lambda { |serviceid| { :conditions => { :service_id => serviceid } } }
	named_scope :by_attendee, lambda { |attendee| { :conditions => { :attendee => attendee } } }
	named_scope :service_state, lambda { |service_state| { :conditions => { :service_state => service_state } } }
	#Needs improvements
	named_scope :service_group, lambda { |id| { :conditions => { :service_id => Servicegroup.find_by_id(id).service_ids } } }

	#Is there a new comment in the last 24 hours (default) ?
	def new_comment?(time = 24.hour.ago)
		!alarmcomments.recent(time).empty?
	end

end
