class ServicesController < ApplicationController
	def index
		#@services = Service.find(:all)
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
		@graphStatus = generateServiceGraphs @service.id
		@graphName = "service_" + @service.id.to_s + "-response.png"
	end

	def delete
		service = Service.find_by_id params[:id]
		if service.destroy
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

end
