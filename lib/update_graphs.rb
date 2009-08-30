#!/usr/bin/ruby -w

require "rubygems"
require "mysql"

environment = "production"
mysql_host = "localhost"

fullpath = "/var/www/scopeport-demo"

begin
  config = YAML::load File.open(fullpath + "/config/database.yml")
  raise "Environment '#{environment}' not configured in database.yml!" if config[environment] == nil
  mysql_user = config[environment]["username"].to_s
  mysql_pass = config[environment]["password"].to_s
  mysql_database = config[environment]["database"].to_s
rescue => e
  puts "Could not read configuration - Error: #{e}"
  exit
end

begin 
  # Connect to MySQL 
  con = Mysql.real_connect mysql_host, mysql_user, mysql_pass, mysql_database
  puts "Connected to MySQL #{con.get_server_info}"
rescue Mysql::Error => e 
  puts "Could not connect to MySQL Server - Error: #{e.error}" 
  con.close if con
  exit
end  

rrdtool_binary = `which rrdtool`.chop

services = con.query "SELECT id, name FROM services"

# RELATIVE/ABSOLUTE PATHS
# SHELL ESCAPE

while service = services.fetch_row
  begin
    puts "=== Service '#{service[1]}' ==="
    rrd_filename = fullpath + "/db/colored-rrds/service-#{service[0].to_s}.rrd"
    rrd = File.open rrd_filename
    last_value = `#{rrdtool_binary} last #{rrd_filename} 2>/dev/null`
    puts "Last stored value is from #{Time.at last_value.to_i}"
    query = "SELECT timestamp, ms FROM servicerecords "
    query << "WHERE serviceid = #{service[0].to_s} "
    query << "AND timestamp > #{last_value.to_i} "
    query << "GROUP BY timestamp "
    query << "ORDER BY timestamp ASC"
    records = con.query query
    puts "Inserting #{records.num_rows} values into RRD..."
    while record = records.fetch_row
      `#{rrdtool_binary} update #{rrd_filename} #{record[0].to_i}:#{record[1].to_i} 2>/dev/null`
    end
  rescue => e
    puts "Error: #{e}"
    next
  end
end

con.close if con
