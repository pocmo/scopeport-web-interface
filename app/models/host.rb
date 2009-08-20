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

class Host < ActiveRecord::Base
	validates_presence_of :name
	validates_presence_of :password
	validates_presence_of :description
	validates_presence_of :os
	validates_presence_of :hostgroup_id
	validates_numericality_of :hostgroup_id

  has_many :recentsensorvalues
  has_many :sensorconditions

  def outdated?
    val = Recentsensorvalue.find_by_host_id self.id, :order => "created_at DESC", :limit => 1
    return false if val.blank?
    return true if val.created_at < 2.minutes.ago
    return false
  end

  def has_sensor_warnings?
    sensorconditions.each do |condition|
      sensor = Recentsensorvalue.find_by_host_id_and_name self.id, Host::shortToLongSensorName(condition.sensor)
      next if condition.blank? or sensor.blank?
      if condition.operator == ">"
        next if sensor.value > condition.value
        return true
      elsif condition.operator == "<"
        next if sensor.value < condition.value
        return true
      elsif condition.operator == "="
        next if sensor.value == condition.value
        return true
      end
    end
    return false
  end

  def self.longToShortSensorName sensor
    case sensor
      when "cpu_load_average_1": "cpu1"
      when "cpu_load_average_5": "cpu5"
      when "cpu_load_average_15": "cpu15"
      when "open_files": "of"
      when "running_processes": "rp"
      when "total_processes": "tp"
      when "free_inodes": "fi"
      when "free_memory": "fm"
      when "free_swap": "fs"
      else "unknown"
    end
  end
  
  def self.shortToLongSensorName sensor
    case sensor
      when "cpu1": "cpu_load_average_1"
      when "cpu5": "cpu_load_average_5"
      when "cpu15": "cpu_load_average_15"
      when "of": "open_files"
      when "rp": "running_processes"
      when "tp": "total_processes"
      when "fi": "free_inodes"
      when "fm": "free_memory"
      when "fs": "free_swap"
      else "unknown"
    end
  end 
  

end
