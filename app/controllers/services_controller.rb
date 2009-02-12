class ServicesController < ApplicationController
	def index
		@services = Service.find_all_by_disabled 0
		@serviceCount = @services.size
	end
	
	def new
		@service = Service.new
		@notigroups = Notificationgroupdetail.find(:all).collect {|p| [p.name, p.id] }
		@notigroups << ["None", "0"]	
		@hosts = Host.find(:all).collect {|p| [p.name, p.id] }
		@hosts << ["None", "0"]	
	end

	def	create
		@service = Service.new(params[:service])
		@notigroups = Notificationgroupdetail.find(:all).collect {|p| [p.name, p.id] }
		@notigroups << ["None", "0"]	
		@hosts = Host.find(:all).collect {|p| [p.name, p.id] }
		@hosts << ["None", "0"]
		if @service.save
			flash[:notice] = "Service has been added!"
			redirect_to :action => "index"
		else
			flash[:error] = "Could not add service. Check error messages."
			render :action => "new"
		end	
	end

	def show
		@service = Service.find_by_id params[:id]
    redirect_to :action => "index" if @service.blank?

    # Create graph (will be skipped if it already exists)
    @graph = RRDGraph.new "service-#{@service.id}"
    @graph.create_rrd "--start NOW --step 60 DS:response:GAUGE:600:U:U RRA:AVERAGE:0.5:6:44640"

    # Fill graph
    yesterday = (Time.now - 86400).to_i
    data = Servicerecord.find :all,
            :conditions => ["timestamp > ? AND timestamp > ? AND serviceid = ?",
                              yesterday.to_s, @graph.get_last_rrd_update, @service.id]
    data.each do |d|
      @graph.insert "#{d.timestamp}:#{d.ms}"
    end

    # Graph image
    lines = ["DEF:response=#{@graph.get_path_of_rrd}:response:AVERAGE LINE:response#eb7f00:'Response time (ms)'"]
    title = "Response time of \"#{@service.name}\" - #{Time.now.to_s}"
    width = "800"
    height = "150"
    options = "-Y -X 1"
    colors = { "SHADEA" => "#F8F8F8",
               "SHADEB" => "#F8F8F8",
               "FONT" => "#000000",
               "BACK" => "#F8F8F8",
               "CANVAS" => "#F8F8F8",
               "GRID" => "#696969",
               "MGRID" => "#877254",
               "AXIS" => "#BDBDBD",
               "ARROW" => "#BDBDBD" }
    @graph.update_image yesterday, Time.now.to_i, lines, title, width, height, colors, options

    @new_comment = Servicecomment.new
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
end
