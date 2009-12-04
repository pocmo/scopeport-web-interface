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
    @disabled_graphs = get_disabled_graphs_hash params[:id]
  end

	def new
		@host = Host.new
		@notigroups = [["None", 0]]
		@notigroups.concat Notificationgroupdetail.find(:all).collect { |p| [p.name, p.id] }
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }
	end

	def create
		@host = Host.new params[:host]
		@notigroups = [["None", 0]]
		@notigroups.concat Notificationgroupdetail.find(:all).collect { |p| [p.name, p.id] }
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }
		
    if @host.save
      log("added", "a host", [@host.name, @host.id])
      flash[:notice] = "Host has been added!"
			redirect_to :controller => "overview"
		else
      flash[:error] = "Could not add host."
			render :action => "new"
		end
	end
  
  def edit
    @host = Host.find params[:id]
		@notigroups = [["None", 0]]
		@notigroups.concat Notificationgroupdetail.find(:all).collect { |p| [p.name, p.id] }
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }
  end

  def update
    @host = Host.update params[:id], params[:host]
		@notigroups = [["None", 0]]
		@notigroups.concat Notificationgroupdetail.find(:all).collect { |p| [p.name, p.id] }
		@hostgroups = Hostgroup.find(:all).collect { |h| [h.name, h.id] }
		@hostgroups << ["None", 0]
    @os_types = { "Linux" => "linux" }

    if @host.save
      log("updated", "a host", [@host.name, @host.id])
      flash[:notice] = "Host has been updated!"
			redirect_to :action => "show", :id => @host.id
    else
      flash[:error] = "Could not update host."
			render :action => "edit"
    end
  end
	
  def store_comment
    comment = Hostcomment.new params[:new_comment]

    host_id = params[:new_comment][:host_id]
    user_id = current_user.id
    if host_id.blank? || user_id.blank?
      flash[:error] = "Could not add comment: Missing parameters."
      redirect_to :action => "index"
      return
    end

    comment.host_id = host_id
    comment.user_id = user_id

    if comment.save
      flash[:notice] = "Comment has been added."
      log("commented", "on a host", comment.host_id)
    else
      flash[:error] = "Could not add comment! Please fill out all fields."
    end
    redirect_to :action => "show", :id => host_id
  end
  
  def deletecomment
    comment = Hostcomment.find params[:id]
    if comment.nil?
      render :text => "Comment not found"
      return
    end
    
    if comment.user_id == current_user.id
      if comment.destroy
        render :text => "Comment deleted."
      else
        render :text => "Could not delete comment."
      end
      return
    end

    render :text => "This is not your comment."
  end

  def graphs
    @host = Host.find params[:id]
    @disabled_graphs = get_disabled_graphs_hash params[:id]
  end

  def updategraphs
    # Delete all existing disabled graphs from this host.
    Disabledgraph.delete_all ["host_id = ?", params[:id]]

    redirect_to :action => "show", :id => params[:id] if params[:graph].blank?

    # Insert all selected graphs into database.
    begin
      params[:graph].each do |graph, disable|
        if disable == "1"
          d = Disabledgraph.new
          d.host_id = params[:id]
          d.name = graph
          d.disabled = true
          d.save
        end
      end
    rescue
      flash[:error] = "Could not update graphs."
      redirect_to :action => "show", :id => params[:id]
      return
    end

    flash[:notice] = "Graphs have been updated!"
    redirect_to :action => "show", :id => params[:id]
  end

  def show_graph_cpuload
		@host = Host.find_by_id params[:id]
    redirect_to :action => "index" if @host.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "host-cpuload-#{@host.id}"
    @graph.create_rrd "--start #{31.days.ago.to_i} --step 60 DS:cpu1:GAUGE:600:U:U DS:cpu5:GAUGE:600:U:U DS:cpu15:GAUGE:600:U:U RRA:AVERAGE:0.5:3:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days].to_i
    data1 = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'cpu_load_average_1'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]
    data5 = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'cpu_load_average_5'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]
    data15 = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'cpu_load_average_15'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]

    data = Array.new
    i = 0
    data1.each do |d|
      data[i] = { "timestamp" => d.created_at.to_i, "cpu1" => d.value, "cpu5" => nil, "cpu15" => nil }
      i += 1
    end

    i = 0
    data5.each do |d|
      data[i]["cpu5"] = d.value unless data[i].blank?
      i += 1
    end
    
    i = 0
    data15.each do |d|
      data[i]["cpu15"] = d.value unless data[i].blank?
      i += 1
    end

    data.each do |d|
      @graph.insert "#{d["timestamp"]}:#{d["cpu1"]}:#{d["cpu5"]}:#{d["cpu15"]}"
    end

    # Graph image
    lines = Array.new
    lines << "DEF:cpu1=#{@graph.get_path_of_rrd}:cpu1:AVERAGE AREA:cpu1#fbcf00:'CPU load average, last minute'"
    lines << "DEF:cpu5=#{@graph.get_path_of_rrd}:cpu5:AVERAGE LINE2:cpu5#ff0000:'CPU load average, last 5 minutes'"
    lines << "DEF:cpu15=#{@graph.get_path_of_rrd}:cpu15:AVERAGE LINE2:cpu15#ff00ff:'CPU load average, last 15 minutes'"
    title = "CPU load average - #{Time.now.to_s}"
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

  def show_graph_rp
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
      @graph.insert "#{d.created_at.to_i}:#{d.value.to_i}"
    end

    # Graph image
    lines = ["DEF:runprocs=#{@graph.get_path_of_rrd}:runprocs:AVERAGE DEF:runprocs2=#{@graph.get_path_of_rrd}:runprocs:AVERAGE:step=750 LINE:runprocs#eb7f00:'Running processes' LINE2:runprocs2#ff0000"]
    title = "Running processes - #{Time.now.to_s}"
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

  def show_graph_tp
		@host = Host.find_by_id params[:id]
    redirect_to :action => "index" if @host.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "host-total-processes-#{@host.id}"
    @graph.create_rrd "--start #{31.days.ago.to_i} --step 60 DS:totprocs:GAUGE:600:U:U RRA:AVERAGE:0.5:3:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days].to_i
    data = Sensorvalue.find :all,
              :conditions => ["created_at > ? AND host_id = ? AND name = 'total_processes'", Time.at(@graph.get_last_rrd_update.to_i), @host.id]

    data.each do |d|
      @graph.insert "#{d.created_at.to_i}:#{d.value.to_i}"
    end

    # Graph image
    lines = ["DEF:totprocs=#{@graph.get_path_of_rrd}:totprocs:AVERAGE DEF:totprocs2=#{@graph.get_path_of_rrd}:totprocs:AVERAGE:step=750 LINE:totprocs#eb7f00:'Total processes' LINE2:totprocs2#ff0000"]
    title = "Total processes - #{Time.now.to_s}"
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

  def show_graph_fm
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
      @graph.insert "#{d.created_at.to_i}:#{d.value.to_i}"
    end

    # Graph image
    lines = ["DEF:freemem=#{@graph.get_path_of_rrd}:freemem:AVERAGE AREA:freemem#eb7f00:'Free memory (kB)'"]
    title = "Free memory - #{Time.now.to_s}"
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
  
  def show_graph_of
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
      @graph.insert "#{d.created_at.to_i}:#{d.value.to_i}"
    end

    # Graph image
    lines = ["DEF:openfiles=#{@graph.get_path_of_rrd}:openfiles:AVERAGE AREA:openfiles#eb7f00:'Open files'"]
    title = "Open files - #{Time.now.to_s}"
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
  
  def show_graph_dr
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
      @graph.insert "#{d.created_at.to_i}:#{d.value.to_i}"
    end

    # Graph image
    lines = ["DEF:readops=#{@graph.get_path_of_rrd}:readops:AVERAGE LINE:readops#eb7f00:'Read operations / minute'"]
    title = "Read operations - #{Time.now.to_s}"
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
  
  def show_graph_dw
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
      @graph.insert "#{d.created_at.to_i}:#{d.value.to_i}"
    end

    # Graph image
    lines = ["DEF:writeops=#{@graph.get_path_of_rrd}:writeops:AVERAGE LINE:writeops#eb7f00:'Write operations / minute'"]
    title = "Write operations - #{Time.now.to_s}"
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
      { "new_comment" => host.new_comment?,
        "outdated" => host.outdated?,
        "id" => host.id,
        "name" => host.name,
        "cpu1" => Host::getLastSensorValue(host.id, "cpu_load_average_1"),
        "cpu5" => Host::getLastSensorValue(host.id, "cpu_load_average_5"),
        "cpu15" => Host::getLastSensorValue(host.id, "cpu_load_average_15"),
        "fm" => Host::getLastSensorValue(host.id, "free_memory"),
        "fs" => Host::getLastSensorValue(host.id, "free_swap"),
        "of" => Host::getLastSensorValue(host.id, "open_files"),
        "fi" => Host::getLastSensorValue(host.id, "free_inodes"),
        "rp" => Host::getLastSensorValue(host.id, "running_processes"),
        "tp" => Host::getLastSensorValue(host.id, "total_processes") }
  end

  def get_conditions_hash host
    conditions = Sensorcondition.find_all_by_host_id host.id
    ret = Hash.new
    conditions.each do |condition|
      ret[condition.sensor] = "#{condition.operator} #{condition.value}"
    end
    return ret
  end

  def get_disabled_graphs_hash host_id
    graphs = Disabledgraph.find_all_by_host_id host_id
    @disabled_graphs = Hash.new
    graphs.each do |graph|
      @disabled_graphs[graph.name] = true
    end

    return @disabled_graphs
  end

end
