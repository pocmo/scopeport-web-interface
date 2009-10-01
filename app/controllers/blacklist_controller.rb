class BlacklistController < ApplicationController

	before_filter(:except => [:index]) { |controller| controller.block unless controller.permission?}
	
	def index
		@blacklisted_hosts = BlacklistedHost.find :all
	end

	def delete
    host = BlacklistedHost.find params[:id]
    if host.destroy
      flash[:notice] = "Host has been removed from blacklist!"
      log("removed", "a host from blacklist", host.host)
    else
      flash[:error] = "Could not remove host."
    end
    redirect_to :action => "index"
	end

  def clear
    if BlacklistedHost.destroy_all
      flash[:notice] = "Cleared blacklist!"
      log("cleared", "the blacklist")
    else
      flash[:error] = "Could not clear blacklist."
    end
    redirect_to :action => "index"
  end

end
