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

class Setting < ActiveRecord::Base
  
#  ScopePort Server Settings
  validates_presence_of :spport, :server
  
#  Ports fields
  validates_numericality_of :spport, :mail_port, :xmpp_port, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 65535, :message => "This is not a valid port"
  
# Mail Server Settings
  validates_presence_of :mail_server, :mail_user, :mail_pass, :if => Proc.new  {|setting| setting.mail_enabled }
  validates_presence_of :mail_user, :mail_pass, :if => Proc.new  {|setting| setting.mail_useauth }
  
# XMPP/Jabber Server Settings
  validates_presence_of :xmpp_server, :xmpp_user, :xmpp_pass, :xmpp_port, :if => Proc.new  {|setting| setting.xmpp_enabled }
  
# Clickatell API Settings   
  validates_presence_of :mobilecUsername, :mobilecPassword, :mobilecAPIID, :if => Proc.new  {|setting| setting.doMobileClickatell }
end
