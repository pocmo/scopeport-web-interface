class BlacklistController < ApplicationController
	def index
		@blacklisted_hosts = BlacklistedHost.find :all
	end

	def delete
    if params[:id].blank? || params[:id].length <= 0
      flash[:error] = "Could not remove host from blacklist. Missing ID."
      redirect_to :action => "index"
      return
    end

    host = BlacklistedHost.find(params[:id])
    if host.destroy
      flash[:notice] = "Host has been removed from blacklist!"
    else
      flash[:error] = "Could not remove host."
    end
    redirect_to :action => "index"
	end

end