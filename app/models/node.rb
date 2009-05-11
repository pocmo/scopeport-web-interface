class Node < ActiveRecord::Base
  validates_presence_of :name, :ip_or_hostname, :port
	validates_numericality_of :port, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 65535, :message => "This is not a valid port"
end
