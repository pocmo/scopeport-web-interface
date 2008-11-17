
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
	validates_presence_of :name
	validates_presence_of :host
	validates_presence_of :service_type
	validates_presence_of :port
	validates_presence_of :maxres
	validates_presence_of :timeout
	validates_presence_of :warninggroup

	validates_numericality_of :port
	validates_numericality_of :maxres
	validates_numericality_of :timeout
	validates_numericality_of :warninggroup
	validates_numericality_of :linkedhost
end
