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

	
	named_scope :created_at, lambda { |time|  { :conditions => ["timestamp > ?", time.to_i ] } }
	named_scope :attended, lambda { |status| {:conditions => { :status => status } } }
	named_scope :from_service, lambda { |serviceid| { :conditions => { :service_id => serviceid } } }
	named_scope :by_attendee, lambda { |attendee| { :conditions => { :attendee => attendee } } }
end
