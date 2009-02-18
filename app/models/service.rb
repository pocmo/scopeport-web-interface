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

class Service < ActiveRecord::Base
	validates_presence_of :name, :host, :service_type, :port, :maxres, :timeout, :warninggroup
	validates_numericality_of :maxres, :timeout, :warninggroup, :linkedhost

	# The port must be between 0 and 65535
	validates_numericality_of :port, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 65535, :message => "This is not a valid port"

  # Belongs to a service group.
  belongs_to :servicegroup

  # Service comments.
  has_many :servicecomments, :order => "created_at DESC"

end
