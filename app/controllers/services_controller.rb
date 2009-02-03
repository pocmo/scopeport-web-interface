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

		@graphStatus = generateServiceGraphs @service.id
		@graphName = "service_" + @service.id.to_s + "-response.png"

    @new_comment = Servicecomment.new
	end

	def delete
		service = Service.find_by_id params[:id]
    alarms = Alarm.find_by_serviceid params[:id]
		if service.destroy && alarms.destroy
			flash[:notice] = "Service has been deleted!"
			redirect_to :action => "index"
		else
			flash[:notice] = "Service could not be deleted."
			redirect_to :action => "show", :id => params[:id]
		end
	end

	def show_graph
		graphStatus = generateServiceGraphs params[:id]
		graphName = "service_" + params[:id] + "-response.png"

		# Output the graph if generating worked.
		if graphStatus == 1
			render :text => '<img src="/images/graphs/' + graphName + '" alt="" />'
			return
		end

		# Generating the graph failed.
		render :text => '<strong>Internal error. Could not create graph</strong>'
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

end
