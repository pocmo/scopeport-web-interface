class SearchController < ApplicationController
  layout nil

  def showresults
    @services = Service.find :all,
                             :conditions => [ "name LIKE ? OR host LIKE ? OR service_type = ?", "%#{params[:query_string]}%", "%#{params[:query_string]}%", params[:query_string] ]

    @hosts = Host.find :all, :conditions => [ "name LIKE ? OR hostname LIKE ?", "%#{params[:query_string]}%", "%#{params[:query_string]}%" ]
  end
end
