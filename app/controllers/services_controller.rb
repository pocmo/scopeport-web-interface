class ServicesController < ApplicationController

	before_filter(:except => [:index, :show, :show_graph, :show_ms, :store_comment]) { |controller| controller.block unless controller.permission?}
	
	def index
		@service_groups = Servicegroup.find :all
    @services_without_group = Service.find_all_by_servicegroup_id 0
    

    # Count the services
		@service_count = 0
    @service_count = @service_count + @services_without_group.size
    @service_groups.each do |group|
      @service_count = @service_count + group.services.count
    end
	end
	
	def new
		@service = Service.new
		@notigroups = [["None", 0]]
		@notigroups.concat Notificationgroupdetail.find(:all).collect { |p| [p.name, p.id] }
		@hosts = Host.find(:all).collect { |p| [p.name, p.id] }
		@hosts << ["None", 0]
    @service_groups = Servicegroup.find(:all).collect { |g| [g.name, g.id] }
    @service_groups << ["None", 0]
	end

	def	create
		@service = Service.new(params[:service])
		@notigroups = Notificationgroupdetail.find(:all).collect {|p| [p.name, p.id] }
		@notigroups << ["None", 0]	
		@hosts = Host.find(:all).collect {|p| [p.name, p.id] }
		@hosts << ["None", 0]
    @service_groups = Servicegroup.find(:all).collect { |g| [g.name, g.id] }
    @service_groups << ["None", 0]
		if @service.save
			flash[:notice] = "Service has been added!"
			log("created", "a service", [@service.name, @service.id])
			redirect_to :action => "index"
		else
			flash[:error] = "Could not add service. Check error messages."
			render :action => "new"
		end	
	end

	def show
		@service = Service.find_by_id params[:id]
    redirect_to :action => "index" if @service.blank?
    @new_comment = Servicecomment.new
	end

  def show_graph
		@service = Service.find_by_id params[:id]
    redirect_to :action => "index" if @service.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "service-#{@service.id}"
    @graph.create_rrd "--start NOW --step 60 DS:response:GAUGE:600:U:U RRA:AVERAGE:0.5:6:44640"

    # Fill graph
    params[:graph_days].blank? ? days = 1 : days = params[:graph_days]
    backwards = (Time.now - (86400*days)).to_i
    data = Servicerecord.find :all,
            :conditions => ["timestamp > ? AND timestamp > ? AND serviceid = ?",
                              backwards.to_s, @graph.get_last_rrd_update, @service.id]
    data.each do |d|
      @graph.insert "#{d.timestamp}:#{d.ms}"
    end

    maxres = 0
    maxres = @service.maxres unless @service.maxres.blank?
    # Graph image
    lines = ["DEF:response=#{@graph.get_path_of_rrd}:response:AVERAGE LINE:response#eb7f00:'Response time (ms)'"]
    title = "Response time of \"#{@service.name}\" - #{Time.now.to_s}"
    width = "800"
    height = "150"
    options = "HRULE:#{maxres}#FF6C6C:'Maximum response time (#{maxres}ms)' -Y -X 1 -E"
    colors = { "SHADEA" => "#F8F8F8",
               "SHADEB" => "#F8F8F8",
               "FONT" => "#000000",
               "BACK" => "#F8F8F8",
               "CANVAS" => "#F8F8F8",
               "GRID" => "#696969",
               "MGRID" => "#877254",
               "AXIS" => "#BDBDBD",
               "ARROW" => "#BDBDBD" }
    @graph.update_image backwards, Time.now.to_i, lines, title, width, height, colors, options

    # Read the graph.
    graph_file = File.new @graph.get_path_of_png, "r"

    # Return the inlined image HTML code to avoid AJAX madness.
    render :text => "<img src=\"data:image/png;base64,#{Base64.encode64(graph_file.read)}\" alt=\"Graph\">"
  end

  def show_ms
    service = Service.find params[:id]
    returnage = ""
    unless service.blank? && service.responsetime.blank?
      if service.state and service.state > 0 and service.state != 4
        returnage = "#{service.responsetime} ms (Maximum: #{service.maxres} ms)"
      else
        returnage = "N/A"
      end
    end
    render :text => returnage
  end

  def edit
    @service = Service.find params[:id]
		@notigroups = Notificationgroupdetail.find(:all).collect {|p| [p.name, p.id] }
		@notigroups << ["None", 0]	
		@hosts = Host.find(:all).collect {|p| [p.name, p.id] }
		@hosts << ["None", 0]	
    @service_groups = Servicegroup.find(:all).collect { |g| [g.name, g.id] }
    @service_groups << ["None", 0]
  end

  def update
    @service = Service.update params[:id], params[:service]
		@notigroups = Notificationgroupdetail.find(:all).collect {|p| [p.name, p.id] }
		@notigroups << ["None", 0]	
		@hosts = Host.find(:all).collect {|p| [p.name, p.id] }
		@hosts << ["None", 0]
    @service_groups = Servicegroup.find(:all).collect { |g| [g.name, g.id] }
    @service_groups << ["None", 0]
    
    if @service.save
      flash[:notice] = "Service has been saved."
      log("updated", "a service", [@service.name, @service.id])
      redirect_to :action => "show", :id => params[:id]
    else
      flash[:error] = "Could not save service."
      render :action => "edit"
    end
  end

	def delete
		service = Service.find_by_id params[:id]
    if service.blank?
      flash[:error] = "Service does not exist."
			redirect_to :action => "index"
      return
    end
		if service.destroy
			flash[:notice] = "Service has been deleted!"
			log("deleted", "a service", service.name)
			redirect_to :action => "index"
		else
			flash[:error] = "Service could not be deleted."
			redirect_to :action => "show", :id => params[:id]
		end
	end

  def store_comment
    comment = Servicecomment.new params[:new_comment]

    service_id = params[:new_comment][:service_id]
    user_id = current_user.id
    if service_id.blank? || user_id.blank?
      flash[:error] = "Could not add comment: Missing parameters."
      redirect_to :action => "index"
      return
    end

    comment.service_id = service_id
    comment.user_id = user_id

    if comment.save
      flash[:notice] = "Comment has been added."
      log("commented", "on a service", comment.service_id)
    else
      flash[:error] = "Could not add comment! Please fill out all fields."
    end
    redirect_to :action => "show", :id => service_id
  end

  def deletecomment
    comment = Servicecomment.find params[:id]
    if comment.nil?
      render :text => "Comment not found"
      return
    end

    # Only allow deletion of comments owned by this user.
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
  
  def allcomments
  	
  	@services = Service.find(:all)
  	
  end
end
