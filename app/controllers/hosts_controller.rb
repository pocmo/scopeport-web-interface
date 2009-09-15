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

class HostsController < ApplicationController

	before_filter { |controller| controller.block unless controller.permission?}

  def index
    @raw_hosts = Host.find :all
    @hosts = Array.new
    @raw_hosts.each do |host|
      @hosts << get_host_sensors_hash(host)
    end
  end

  def show
    @host = Host.find params[:id]
    @sensors = get_host_sensors_hash @host
    @conditions = get_conditions_hash @host
  end

	def new
		@host = Host.new
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }
	end

	def create
		@host = Host.new params[:host]
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }
		
    if @host.save
      log("added", "a host", [@host.name, @host.id])
      flash[:notice] = "Host has been added!"
      log("added", "a host", [@host.name, @host.id])
			redirect_to :controller => "overview"
		else
      flash[:error] = "Could not add host."
			render :action => "new"
		end
	end
  
  def show_processes_graph
		@host = Host.find_by_id params[:id]
    redirect_to :action => "index" if @host.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "host-processes-#{@host.id}"
    @graph.create_rrd "--start #{31.days.ago.to_i} --step 60 DS:runprocs:GAUGE:600:U:U RRA:AVERAGE:0.5:3:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days].to_i
    data = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'running_processes'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]

    data.each do |d|
      @graph.insert "#{d.created_at.to_i}:#{d.value}"
    end

    # Graph image
    lines = ["DEF:runprocs=#{@graph.get_path_of_rrd}:runprocs:AVERAGE LINE:runprocs#eb7f00:'Running processes'"]
    title = "Running processes on host \"#{@host.name}\" - #{Time.now.to_s}"
    width = "800"
    height = "150"
    options = ""
    colors = { "SHADEA" => "#F8F8F8",
               "SHADEB" => "#F8F8F8",
               "FONT" => "#000000",
               "BACK" => "#F8F8F8",
               "CANVAS" => "#F8F8F8",
               "GRID" => "#696969",
               "MGRID" => "#877254",
               "AXIS" => "#BDBDBD",
               "ARROW" => "#BDBDBD" }

    backwards = (Time.now - (86400*days)).to_i
    @graph.update_image backwards, Time.now.to_i, lines, title, width, height, colors, options

    # Read the graph.
    graph_file = File.new @graph.get_path_of_png, "r"

    # Return the inlined image HTML code to avoid AJAX madness.
    render :text => "<img src=\"data:image/png;base64,#{Base64.encode64(graph_file.read)}\" alt=\"Graph\">"
  end

  def show_free_memory_graph
		@host = Host.find_by_id params[:id]
    redirect_to :action => "index" if @host.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "host-free-memory-#{@host.id}"
    @graph.create_rrd "--start #{31.days.ago.to_i} --step 60 DS:freemem:GAUGE:600:U:U RRA:AVERAGE:0.5:3:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days].to_i
    data = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'free_memory'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]

    data.each do |d|
      @graph.insert "#{d.created_at.to_i}:#{d.value}"
    end

    # Graph image
    lines = ["DEF:freemem=#{@graph.get_path_of_rrd}:freemem:AVERAGE AREA:freemem#eb7f00:'Free memory (kB)'"]
    title = "Free memory on host \"#{@host.name}\" - #{Time.now.to_s}"
    width = "800"
    height = "150"
    options = "--base 1024 -X 0"
    colors = { "SHADEA" => "#F8F8F8",
               "SHADEB" => "#F8F8F8",
               "FONT" => "#000000",
               "BACK" => "#F8F8F8",
               "CANVAS" => "#F8F8F8",
               "GRID" => "#696969",
               "MGRID" => "#877254",
               "AXIS" => "#BDBDBD",
               "ARROW" => "#BDBDBD" }

    backwards = (Time.now - (86400*days)).to_i
    @graph.update_image backwards, Time.now.to_i, lines, title, width, height, colors, options

    # Read the graph.
    graph_file = File.new @graph.get_path_of_png, "r"

    # Return the inlined image HTML code to avoid AJAX madness.
    render :text => "<img src=\"data:image/png;base64,#{Base64.encode64(graph_file.read)}\" alt=\"Graph\">"
  end
  
  def show_open_files_graph
		@host = Host.find_by_id params[:id]
    redirect_to :action => "index" if @host.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "host-open-files-#{@host.id}"
    @graph.create_rrd "--start #{31.days.ago.to_i} --step 60 DS:openfiles:GAUGE:600:U:U RRA:AVERAGE:0.5:3:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days].to_i
    data = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'open_files'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]

    data.each do |d|
      @graph.insert "#{d.created_at.to_i}:#{d.value}"
    end

    # Graph image
    lines = ["DEF:openfiles=#{@graph.get_path_of_rrd}:openfiles:AVERAGE AREA:openfiles#eb7f00:'Open files'"]
    title = "Open files on host \"#{@host.name}\" - #{Time.now.to_s}"
    width = "800"
    height = "150"
    options = "--base 1024 -X 0"
    colors = { "SHADEA" => "#F8F8F8",
               "SHADEB" => "#F8F8F8",
               "FONT" => "#000000",
               "BACK" => "#F8F8F8",
               "CANVAS" => "#F8F8F8",
               "GRID" => "#696969",
               "MGRID" => "#877254",
               "AXIS" => "#BDBDBD",
               "ARROW" => "#BDBDBD" }

    backwards = (Time.now - (86400*days)).to_i
    @graph.update_image backwards, Time.now.to_i, lines, title, width, height, colors, options

    # Read the graph.
    graph_file = File.new @graph.get_path_of_png, "r"

    # Return the inlined image HTML code to avoid AJAX madness.
    render :text => "<img src=\"data:image/png;base64,#{Base64.encode64(graph_file.read)}\" alt=\"Graph\">"
  end
  
  def show_disk_read_ops_graph
		@host = Host.find_by_id params[:id]
    redirect_to :action => "index" if @host.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "host-disk-read-ops-#{@host.id}"
    @graph.create_rrd "--start #{31.days.ago.to_i} --step 60 DS:readops:COUNTER:600:U:U RRA:AVERAGE:0.5:3:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days].to_i
    data = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'read_operations'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]

    data.each do |d|
      @graph.insert "#{d.created_at.to_i}:#{d.value}"
    end

    # Graph image
    lines = ["DEF:readops=#{@graph.get_path_of_rrd}:readops:AVERAGE LINE:readops#eb7f00:'Read operations / minute'"]
    title = "Read operations on host \"#{@host.name}\" - #{Time.now.to_s}"
    width = "800"
    height = "150"
    options = ""
    colors = { "SHADEA" => "#F8F8F8",
               "SHADEB" => "#F8F8F8",
               "FONT" => "#000000",
               "BACK" => "#F8F8F8",
               "CANVAS" => "#F8F8F8",
               "GRID" => "#696969",
               "MGRID" => "#877254",
               "AXIS" => "#BDBDBD",
               "ARROW" => "#BDBDBD" }

    backwards = (Time.now - (86400*days)).to_i
    @graph.update_image backwards, Time.now.to_i, lines, title, width, height, colors, options

    # Read the graph.
    graph_file = File.new @graph.get_path_of_png, "r"

    # Return the inlined image HTML code to avoid AJAX madness.
    render :text => "<img src=\"data:image/png;base64,#{Base64.encode64(graph_file.read)}\" alt=\"Graph\">"
  end
  
  def show_disk_write_ops_graph
		@host = Host.find_by_id params[:id]
    redirect_to :action => "index" if @host.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "host-disk-write-ops-#{@host.id}"
    @graph.create_rrd "--start #{31.days.ago.to_i} --step 60 DS:writeops:COUNTER:600:U:U RRA:AVERAGE:0.5:3:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days].to_i
    data = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'write_operations'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]

    data.each do |d|
      @graph.insert "#{d.created_at.to_i}:#{d.value}"
    end

    # Graph image
    lines = ["DEF:writeops=#{@graph.get_path_of_rrd}:writeops:AVERAGE LINE:writeops#eb7f00:'Write operations / minute'"]
    title = "Write operations on host \"#{@host.name}\" - #{Time.now.to_s}"
    width = "800"
    height = "150"
    options = ""
    colors = { "SHADEA" => "#F8F8F8",
               "SHADEB" => "#F8F8F8",
               "FONT" => "#000000",
               "BACK" => "#F8F8F8",
               "CANVAS" => "#F8F8F8",
               "GRID" => "#696969",
               "MGRID" => "#877254",
               "AXIS" => "#BDBDBD",
               "ARROW" => "#BDBDBD" }

    backwards = (Time.now - (86400*days)).to_i
    @graph.update_image backwards, Time.now.to_i, lines, title, width, height, colors, options

    # Read the graph.
    graph_file = File.new @graph.get_path_of_png, "r"

    # Return the inlined image HTML code to avoid AJAX madness.
    render :text => "<img src=\"data:image/png;base64,#{Base64.encode64(graph_file.read)}\" alt=\"Graph\">"
  end

  private

  def get_host_sensors_hash host
      { "outdated" => host.outdated?,
        "id" => host.id,
        "name" => host.name,
        "cpu1" => getLastSensorValue(host.id, "cpu_load_average_1"),
        "cpu5" => getLastSensorValue(host.id, "cpu_load_average_5"),
        "cpu15" => getLastSensorValue(host.id, "cpu_load_average_15"),
        "fm" => getLastSensorValue(host.id, "free_memory"),
        "fs" => getLastSensorValue(host.id, "free_swap"),
        "of" => getLastSensorValue(host.id, "open_files"),
        "fi" => getLastSensorValue(host.id, "free_inodes"),
        "rp" => getLastSensorValue(host.id, "running_processes"),
        "tp" => getLastSensorValue(host.id, "total_processes") }
  end

  def get_conditions_hash host
    conditions = Sensorcondition.find_all_by_host_id host.id
    ret = Hash.new
    conditions.each do |condition|
      ret[condition.sensor] = "#{condition.operator} #{condition.value}"
    end
    return ret
  end

end
