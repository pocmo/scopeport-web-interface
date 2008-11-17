class ServicesController < ApplicationController
	def index
		#@services = Service.find(:all)
		@services = Service.find_all_by_disabled 0
		@serviceCount = @services.count
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
		@notigroups = Notificationgroupdetail.find(:all)
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
		@service = Service.find_by_id(params[:id])
	end

end
