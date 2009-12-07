class ApiController < ApplicationController
  #skip_before_filter :login_required # will be handled by oauth
  #before_filter :oauth_required
  
  private
  
  def host
      build_response(Host, ["index", "show"])
  end
  
  def service
    build_response(Service, ["index", "show"])
  end
  
  def alarm
    build_response(Alarm, ["index", "show"])
  end
  
  def emergency
    build_response(Emergency, ["index", "show"])
  end
  
  def nodes
    build_response(Node, ["index", "show"])
  end
  
  def build_response(model, actions)
    if actions.include? params[:api_action]
      build_index_response(model) if params[:api_action] == "index"
      build_show_response(model) if params[:api_action] == "show"
    else
      api_action_not_defined
    end
  end
  
  def build_show_response(object)
    object = object.find params[:id]
    object.nil? ? empty_object_response : format(object)
  end
  
  def build_index_response(object)
    offset = params[:offset].blank? ? 0 : params[:offset].to_i
    limit = !params[:limit].blank? && params[:limit].to_i <= 100 ?  params[:limit].to_i : 50
    array = object.find :all, :limit => limit, :offset => offset
    array.empty? ? empty_array_response : format(array)
  end
  
  def format(object_or_array)
    respond_to do |format|
      format.xml { render :xml => object_or_array.to_xml }
      format.json { render :json => object_or_array.to_json }
    end
  end
  
  def api_action_not_defined
    render :text => ""
  end
  
  def empty_object_response
    render :text => ""
  end
  
  def empty_array_response
    render :text => ""
  end

end
